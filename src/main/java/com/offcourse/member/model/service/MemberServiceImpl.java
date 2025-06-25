package com.offcourse.member.model.service;

import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.member.model.dto.Member;
import com.offcourse.member.exception.DuplicateMemberException;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationType;
import com.offcourse.notification.model.service.NotificationProducer;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {
    private final MemberDao memberDao;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
    private final NotificationProducer notificationProducer;
    private static final String ATTR_EMAIL    = "authEmail";
    private static final String ATTR_CODE     = "authCode";
    private static final String ATTR_EXPIRE   = "authExpire";
    private static final String ATTR_VERIFIED = "emailVerified";

    @Override
    public void sendAuthCode(String email, HttpSession session) {
        // 6자리 랜덤 코드 생성
        String code = String.format("%06d", new Random().nextInt(1_000_000));
        // 이메일 발송
        mailService.sendEmail(email, "회원가입 인증번호", "인증번호: " + code);
        // 세션에 저장 (이메일, 코드, 만료시간)
        session.setAttribute(ATTR_EMAIL,    email);
        session.setAttribute(ATTR_CODE,     code);
        session.setAttribute(ATTR_EXPIRE,   System.currentTimeMillis() + 5 * 60 * 1000);
        session.setAttribute(ATTR_VERIFIED, false);
    }
    @Override
    public boolean verifyAuthCode(String code, HttpSession session) {
        String sessEmail = (String) session.getAttribute(ATTR_EMAIL);
        String sessCode  = (String) session.getAttribute(ATTR_CODE);
        Long   expire    = (Long)   session.getAttribute(ATTR_EXPIRE);

        if (sessEmail == null || sessCode == null || expire == null) {
            throw new IllegalStateException("인증요청이 없습니다.");
        }
        if (System.currentTimeMillis() > expire) {
            return false;
        }
        boolean ok = sessCode.equals(code);
        if (ok) {
            session.setAttribute(ATTR_VERIFIED, true);
        }
        return ok;
    }
    @Override
    public boolean isEmailVerified(String email, HttpSession session) {
        Boolean verified = (Boolean) session.getAttribute(ATTR_VERIFIED);
        String  sessEmail= (String)  session.getAttribute(ATTR_EMAIL);
        return Boolean.TRUE.equals(verified) && email.equals(sessEmail);
    }

    @Override
    @Transactional
    public int insertMember(Member member,
                            MultipartFile profileFile,
                            MultipartFile portfolioFile,
                            HttpSession session) {

        //ID/EMAIL 중복 체크
        if (memberDao.existsById(member.getMemberId()) > 0) {
            throw new DuplicateMemberException("이미 사용 중인 아이디입니다.");
        }
        if (memberDao.existsByEmail(member.getMemberEmail()) > 0) {
            throw new DuplicateMemberException("이미 등록된 이메일입니다.");
        }

        String profileFileName = null;
        String portfolioFileName = null;
        String profilePath = "";
        String portfolioPath = "";
        try {
            // 1) 비밀번호 암호화
            member.setMemberPwd(passwordEncoder.encode(member.getMemberPwd()));

            // 2) 저장 경로 결정
            profilePath = session.getServletContext().getRealPath(
                    "1".equals(member.getMemberType()) ?
                            "/resources/upload/instructor/profile" :
                            "/resources/upload/student/profile");
            portfolioPath = session.getServletContext().getRealPath(
                    "/resources/upload/instructor/portfolio");

            // 3) 파일 저장
            if (profileFile != null && !profileFile.isEmpty()) {
                profileFileName = saveFile(profileFile, profilePath);
                member.setMemberProfile(profileFileName);
            }
            if ("1".equals(member.getMemberType())
                    && portfolioFile != null && !portfolioFile.isEmpty()) {
                portfolioFileName = saveFile(portfolioFile, portfolioPath);
                member.setPortfolioFileName(portfolioFileName);
            }

            // 4) DB 저장
            int result = memberDao.insertMember(member);
            if (result <= 0) {
                // 실패 시 저장된 파일 삭제
                deleteFile(profilePath, profileFileName);
                deleteFile(portfolioPath, portfolioFileName);
            }

            NotificationEvent event;
            if (member.getMemberType().equals("0")) {
                event = NotificationEvent.builder()
                        .memberSeq(member.getMemberSeq())
                        .msgDate(new Timestamp(System.currentTimeMillis()))
                        .msgType(NotificationType.STUDENT_JOIN_SUCCESS)
                        .redirectLocation(NotificationType.STUDENT_JOIN_SUCCESS.getRedirectLocation())
                        .build();
            } else {
                event = NotificationEvent.builder()
                        .memberSeq(member.getMemberSeq())
                        .msgDate(new Timestamp(System.currentTimeMillis()))
                        .msgType(NotificationType.STUDENT_JOIN_SUCCESS)
                        .redirectLocation(NotificationType.STUDENT_JOIN_SUCCESS.getRedirectLocation())
                        .build();
            }
            notificationProducer.send(event);

            return result;
        } catch (Exception e) {
            // 예외 시 저장된 파일 삭제 후 롤백
            deleteFile(profilePath, profileFileName);
            deleteFile(portfolioPath, portfolioFileName);
            throw new RuntimeException("회원가입 처리 중 오류 발생", e);
        }
    }

    private String saveFile(MultipartFile file, String path) throws IOException {
        String oriName = file.getOriginalFilename();
        String ext = oriName.substring(oriName.lastIndexOf('.'));
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmssSSS").format(new Date());
        int rnd = (int) (Math.random() * 1000) + 1;
        String rename = "offcourse_" + timeStamp + "_" + rnd + ext;

        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();
        file.transferTo(new File(dir, rename));
        return rename;
    }

    private void deleteFile(String path, String fileName) {
        if (fileName != null) {
            File file = new File(path, fileName);
            if (file.exists()) file.delete();
        }
    }


    @Override
    public Member selectMemberById(String memberId) {
        return memberDao.selectMemberById(memberId);
    }

    @Override
    public int updateMember(Member member) {
        return memberDao.updateMember(member);
    }

    @Override
    public int deleteMember(Long memberSeq) {
        return memberDao.deleteMember(memberSeq);
    }

    @Override
    public Member findByEmail(String memberEmail) {
        return memberDao.findByEmail(memberEmail);
    }

    @Override
    public Member findByIdAndEmail(String memberId, String memberEmail) {
        Map<String, Object> map = new HashMap<>();
        map.put("memberId", memberId);
        map.put("memberEmail", memberEmail);
        return memberDao.findByIdAndEmail(map);
    }

    @Override
    @Transactional
    public int updatePassword(String memberId, String memberPwd) {
        Map<String, Object> map = new HashMap<>();
        map.put("memberId", memberId);
        map.put("memberPwd", memberPwd);
        return memberDao.updatePassword(map);
    }

    @Override
    @Transactional
    public boolean resetPassword(String memberId, String memberEmail) {
        // 1) 회원 조회
        Member member = findByIdAndEmail(memberId, memberEmail);
        if (member == null) {
            return false;
        }

        // 2) 임시 비밀번호 생성
        String tempPwd = generateTempPassword();

        // 3) 이메일 발송
        mailService.sendEmail(memberEmail,
                "임시 비밀번호 발급",
                "임시 비밀번호: " + tempPwd);

        // 4) DB 비밀번호 업데이트
        int updated = updatePassword(memberId,
                passwordEncoder.encode(tempPwd));
        return updated > 0;
    }

    private String generateTempPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String special = "!@#$%^&*";

        StringBuilder sb = new StringBuilder();
        sb.append(upper.charAt(new Random().nextInt(upper.length())));
        sb.append(lower.charAt(new Random().nextInt(lower.length())));
        sb.append(digits.charAt(new Random().nextInt(digits.length())));
        sb.append(special.charAt(new Random().nextInt(special.length())));

        String all = upper + lower + digits + special;
        Random rnd = new Random();
        while (sb.length() < 10) {
            sb.append(all.charAt(rnd.nextInt(all.length())));
        }
        List<Character> chars = new ArrayList<>();
        for (char c : sb.toString().toCharArray()) chars.add(c);
        Collections.shuffle(chars);
        StringBuilder pwd = new StringBuilder();
        chars.forEach(pwd::append);
        return pwd.toString();
    }


}