package com.offcourse.member.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
//@Alias("member")
public class Member {

    private Long memberSeq;

    @NotBlank(message = "아이디는 필수 항목입니다.")
    @Size(min = 4, max = 20, message = "아이디는 4~20자 사이로 입력해주세요.")
    private String memberId;

    @NotBlank(message = "비밀번호는 필수 항목입니다.")
    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    @Pattern(
            regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+=-]).{8,}$",
            message = "비밀번호는 영문자, 숫자, 특수문자를 모두 포함해야 합니다."
    )
    private String memberPwd;

    @NotBlank(message = "이름은 필수 항목입니다.")
    private String memberName;

    @NotBlank(message = "닉네임은 필수 항목입니다.")
    private String memberNickname;

    @NotBlank(message = "이메일은 필수 항목입니다.")
    @Email(message = "올바른 이메일 형식이어야 합니다.")
    private String memberEmail;

    @NotBlank(message = "주소는 필수 항목입니다.")
    private String memberAddress; // (기본주소 + 상세주소 자동 합쳐서 세팅 예정)

    @NotBlank(message = "전화번호는 필수 항목입니다.")
    @Pattern(
            regexp = "^\\d{10,11}$",
            message = "전화번호는 숫자만 10~11자리 입력해주세요. (예: 01012345678)"
    )
    private String memberPhone; // 프론트/백에서 '010-xxxx-xxxx' 형식으로 표시

    private String memberType; // 0: 일반, 1: 강사

    private String memberProfile;         // 프로필 이미지 파일명
    private String portfolioFileName;     // 포트폴리오 파일명 (강사 전용)

    private Timestamp memberCreateTime;
    private Timestamp memberDeleteTime;
}
