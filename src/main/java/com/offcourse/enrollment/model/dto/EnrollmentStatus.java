package com.offcourse.enrollment.model.dto;

public enum EnrollmentStatus {
    ENROLL("0"),
    CANCEL("1"),
    COMPLETE("2"),
    INCOMPLETE("3");
    private final String value;

    EnrollmentStatus(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return this.value;
    }
}
