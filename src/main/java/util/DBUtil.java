package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String URL = getRequiredEnv("MINICAMPUS_DB_URL");
    private static final String USER = getRequiredEnv("MINICAMPUS_DB_USER");
    private static final String PASSWORD = getRequiredEnv("MINICAMPUS_DB_PASSWORD");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver 로딩 실패", e);
        }
    }

    private static String getRequiredEnv(String key) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException("필수 환경 변수가 없습니다: " + key);
        }
        return value.trim();
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}