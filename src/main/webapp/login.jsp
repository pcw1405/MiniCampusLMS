package util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBUtil {

    private static final Properties props = new Properties();

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    throw new RuntimeException("db.properties 파일을 찾을 수 없습니다.");
                }
                props.load(input);
            }

        } catch (Exception e) {
            throw new RuntimeException("DB 설정 로딩 실패", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String password = props.getProperty("db.password");

        return DriverManager.getConnection(url, user, password);
    }
}