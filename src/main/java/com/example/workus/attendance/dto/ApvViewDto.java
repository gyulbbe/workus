package com.example.workus.attendance.dto;

import lombok.*;
import org.apache.ibatis.type.Alias;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
@Alias("apvViewDto")
public class ApvViewDto {
    private Long atdNo;
    private String status;
    private String reason;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date fromDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date toDate;
    private Date createdDate;
    private String time;
    private String categoryName;
    private Long apvNo;
    private String reqUserName;
}
