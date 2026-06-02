<HTML> 
<HEAD>
</HEAD>
<body>
    <%
    String k14_arr[] = new String[]{"111","222","333"};
    String k14_str = "abc,efg,hij";
    String k14_str_arr[] = k14_str.split(",");
    %>
    k14_arr[0]:<%=k14_arr[0]%> <br> 
    k14_arr[1]:<%=k14_arr[1]%> <br>
    k14_arr[2]:<%=k14_arr[2]%> <br>
    k14_str_arr[0]:<%=k14_str_arr[0]%> <br>
    k14_str_arr[1]:<%=k14_str_arr[1]%> <br>
    k14_str_arr[2]:<%=k14_str_arr[2]%> <br>
    Good ...
</body>
</HTML>