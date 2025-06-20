package com.offcourse.course.model.dto;

public enum DayCode {
    MONDAY("0", "월"),
    TUESDAY("1", "화"),
    WEDNESDAY("2", "수"),
    THURSDAY("3", "목"),
    FRIDAY("4", "금"),
    SATURDAY("5", "토"),
    SUNDAY("6", "일");

    private final String code;
    private final String name;

    DayCode(String code, String name) {
        this.code = code;
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public static DayCode fromCode(String code) {
        for (DayCode d : values()) {
            if (d.code.equals(code)) {
                return d;
            }
        }
        return null;
    }

}
