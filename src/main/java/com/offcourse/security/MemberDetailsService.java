package com.offcourse.security;

import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberDetailsService implements UserDetailsService {

    private final SqlSession sqlSession;

    /**
     * Spring Security가 로그인 시 호출하는 메서드
     * 입력된 'username'은 우리 시스템에서는 'memberId'에 해당함
     *
     * @param username 로그인 폼에서 입력된 사용자 ID (== memberId)
     * @return UserDetails 객체 (내부적으로는 CustomUserDetails 객체)
     * @throws UsernameNotFoundException 사용자가 존재하지 않으면 예외 발생
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        System.out.println("🔍 로그인 시도 중: " + username);

        // MyBatis 매퍼 인터페이스 구현체 얻기
        MemberDao memberDao = sqlSession.getMapper(MemberDao.class);

        // DB에서 memberId로 회원 정보 조회
        Member member = memberDao.selectMemberById(username);

        // 해당 ID에 대한 회원이 존재하지 않으면 예외 발생
        if (member == null) {
            throw new UsernameNotFoundException("존재하지 않는 회원입니다: " + username);
        }

        // 조회된 회원 정보를 기반으로 Spring Security용 UserDetails 구현체 반환
        return new CustomUserDetails(member);
    }

}
