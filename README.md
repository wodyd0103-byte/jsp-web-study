# JSP Web Study 🌐☕

하이테크 직업교육과정에서 진행한 **JSP + JDBC + MySQL 웹 애플리케이션** 작업물입니다.
Java 웹 풀스택(화면-로직-DB)을 직접 구현하며 학습한 코드입니다.

## 📂 구성

| 폴더/파일 | 내용 |
|---|---|
| `DB01`, `DBAI` | MySQL CRUD 웹앱 (생성·조회·수정·삭제) |
| `freewifi`, `freewifiai` | 공공데이터(무료 와이파이) 활용 앱 |
| `weather*.jsp` | 날씨 데이터 조회·예보·대시보드 |
| `member.jsp`, `login.html` | 회원/로그인 |
| `es1~9.jsp`, `db1.jsp` | JSP·JDBC 기초 실습 |
| `WEB-INF/web.xml` | 웹 애플리케이션 배포 설정 |

## 🛠️ 사용 기술
- **JSP** (JavaServer Pages)
- **JDBC** + **MySQL** (DriverManager 연결)
- **Apache Tomcat 11** 서블릿 컨테이너

## ▶️ 실행 방법
1. MySQL에 데이터베이스 준비
2. JSP 내 `YOUR_DB_PASSWORD` 를 본인 DB 비밀번호로 변경
3. Tomcat `webapps/ROOT/` 에 배치 후 서버 실행
4. `http://localhost:8080/` 접속

## ⚠️ 참고
- DB 접속 비밀번호는 보안을 위해 `YOUR_DB_PASSWORD` placeholder로 대체했습니다.
- 컴파일 결과물·Tomcat 기본 파일·라이브러리(jar)는 제외했습니다.

> 🖼 실행 화면 스크린샷 모음은 [jsp-portfolio](https://github.com/wodyd0103-byte/jsp-portfolio)에서 볼 수 있습니다.
