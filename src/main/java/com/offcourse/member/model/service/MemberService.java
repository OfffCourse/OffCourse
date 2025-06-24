package com.offcourse.member.model.service;

import com.offcourse.member.model.dto.Member;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;

public interface MemberService {

    int insertMember(Member member,
                     MultipartFile profileFile,
                     MultipartFile portfolioFile,
                     HttpSession session);

    Member selectMemberById(String memberId);

    int updateMember(Member member);

    int deleteMember(Long memberSeq);

    Member findByEmail(String memberEmail);

    Member findByIdAndEmail(String memberId, String memberEmail);

    int updatePassword(String memberId, String memberPwd);

    boolean resetPassword(String memberId, String memberEmail);
}