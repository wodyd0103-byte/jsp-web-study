<HTML>
<HEAD>
<%!
private class AA{
    private int Sum(int k14_i, int k14_j){
        return k14_i + k14_j;
    }
}
AA k14_aa = new AA();
%>
</HEAD>
<BODY>
<% out.println("2+3=" +k14_aa.Sum(2,3));%> <br>
Good ...
</BODY>
</HTML>