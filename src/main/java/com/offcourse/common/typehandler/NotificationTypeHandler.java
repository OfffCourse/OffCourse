package com.offcourse.common.typehandler;

import com.offcourse.notification.model.dto.NotificationType;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class NotificationTypeHandler extends BaseTypeHandler<NotificationType> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, NotificationType parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.name()); // 저장할 때 enum 이름 사용
    }

    @Override
    public NotificationType getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String type = rs.getString(columnName);
        return type != null ? NotificationType.valueOf(type) : null;    }

    @Override
    public NotificationType getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String type = rs.getString(columnIndex);
        return type != null ? NotificationType.valueOf(type) : null;    }

    @Override
    public NotificationType getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String type = cs.getString(columnIndex);
        return type != null ? NotificationType.valueOf(type) : null;    }
}
