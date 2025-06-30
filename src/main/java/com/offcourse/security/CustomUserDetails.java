package com.offcourse.security;

import com.offcourse.member.model.dto.Member;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serial;
import java.io.Serializable;
import java.util.Collection;
import java.util.Collections;
import java.util.Objects;

@AllArgsConstructor
@Getter
public class CustomUserDetails implements UserDetails, Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private final Member member;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 권한은 0이면 ROLE_USER, 1이면 ROLE_INSTRUCTOR
        String role;
        if (member.getMemberId().equals("admin")) {
            role = "ROLE_ADMIN";
            return Collections.singleton((() -> role));
        }
        role = member.getMemberType().equals("1") ? "ROLE_INSTRUCTOR" : "ROLE_USER";
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

    // equals(), hashCode() - session concurrency control
    // 세션 만료를 시켜주려면 memberId 기준으로 비교하는 게 필요했음.
    // 여기서 getUsername 으로 memberId 반환하게 하고 있음
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CustomUserDetails that)) return false;
        return Objects.equals(this.getUsername(), that.getUsername());
    }

    @Override
    public int hashCode() {
        return Objects.hash(this.getUsername());
    }
}
