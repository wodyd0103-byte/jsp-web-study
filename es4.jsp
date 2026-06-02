<%@ page contentType="text/html; charset=UTF-8" %>
<HTML>
<HEAD>
<%! //함수나 변수 선언시 !
private String k14_call1(){
	String k14_a = "abc";
	String k14_b = "efg";
	return (k14_a+k14_b);
}
private Integer k14_call2(){
	Integer k14_a = 1;
	Integer k14_b = 2;
	return (k14_a+k14_b);
}
%>
</HEAD>
<BODY>
String연산 :<%=k14_call1()%><br>
Integer연산 :<%=k14_call2()%><br>
Good ...
</BODY>
</HTML>