package com.offcourse.member.model.service;

public class DuplicateMemberException extends RuntimeException {
    public DuplicateMemberException(String message) {
        super(message);
    }
}
