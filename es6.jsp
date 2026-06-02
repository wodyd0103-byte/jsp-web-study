<HTML>
<HEAD>
<%!
String k14_str = "abcdfeffasdsd";
int k14_str_len = k14_str.length();
String k14_str_sub = k14_str.substring(5);
int k14_str_loc = k14_str.indexOf("cd");
String k14_strL = k14_str.toLowerCase();
String k14_strU = k14_str.toUpperCase();
%>
</HEAD>
<BODY>
    k14_Str:<%=k14_str%> <br>
    k14_Str_len:<%=k14_str_len%> <br>
    k14_Str_sub:<%=k14_str_sub%> <br>
    k14_Str_loc:<%=k14_str_loc%> <br>
    k14_StrL:<%=k14_strL%> <br>
    k14_StrU:<%=k14_strU%> <br>
Good ...
</BODY>
</HTML>
