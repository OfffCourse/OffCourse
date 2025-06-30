package com.offcourse.member.model.dao;

import com.offcourse.admin.model.dto.MemberAll;
import com.offcourse.member.model.dto.Member;

import java.util.List;
import java.util.Map;

public interface MemberDao {
    int existsById(String memberId);

    int existsByEmail(String memberEmail);

    int insertMember(Member member);

    Member selectMemberById(String memberId);

    int updateMember(Member member);

    int deleteMember(Long memberSeq);

    Member findByEmail(String memberEmail);

    Member findByIdAndEmail(Map<String, Object> paramMap);

    int updatePassword(Map<String, Object> paramMap);

    long countMemberAll();

    long countTeacherAll();

    List<MemberAll> getMemberAllByRole(Map param);

    int countMemberAllByRole(Map param);
}
