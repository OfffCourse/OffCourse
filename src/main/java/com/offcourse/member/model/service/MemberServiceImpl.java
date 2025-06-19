package com.offcourse.member.model.service;

import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final MemberDao memberDao;

    @Override
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
}
