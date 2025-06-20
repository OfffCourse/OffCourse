package com.offcourse.security;

import com.offcourse.member.model.dto.Member;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@AllArgsConstructor
@Getter
public class CustomUserDetails implements UserDetails {

    private final Member member;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 권한은 0이면 ROLE_USER, 1이면 ROLE_INSTRUCTOR
        String role = member.getMemberType().equals("1") ? "ROLE_INSTRUCTOR" : "ROLE_USER";
        return Collections.singleton(() -> role);
    }

    public Long getMemberSeq() {
        return member.getMemberSeq();
    }

    @Override
    public String getPassword() {
        return member.getMemberPwd();
    }

    @Override
    public String getUsername() {
        return member.getMemberId();
    }

    @Override
    public boolean isAccountNonExpired() {
        return member.getMemberDeleteTime() == null;
    }

    @Override
    public boolean isAccountNonLocked() {
        return member.getMemberDeleteTime() == null;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return member.getMemberDeleteTime() == null;
    }

    @Override
    public boolean isEnabled() {
        return member.getMemberDeleteTime() == null;
    }
}
