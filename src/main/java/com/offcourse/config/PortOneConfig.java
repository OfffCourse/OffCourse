package com.offcourse.config;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@Getter
public class PortOneConfig {

    @Value("${portone.imp-code}")
    private String impCode;
}
