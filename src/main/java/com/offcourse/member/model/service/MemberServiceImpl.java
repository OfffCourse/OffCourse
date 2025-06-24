package com.offcourse.member.model.service;

import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final MemberDao memberDao;

    @Override
    @Transactional
    public int insertMember(Member member) {
        return memberDao.insertMember(member);
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

    // MemberServiceImpl
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

}
