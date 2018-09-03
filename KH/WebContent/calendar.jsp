<%@page import="dao.CalendarDAO"%>
<%@page import="dao.CalendarDAOImpl"%>
<%@page import="dto.MemberDto"%>
<%@page import="java.util.Calendar"%>
<%@page import="dto.CalendarDto"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/include/header.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
</head>
<body>

<%!
public boolean nvl(String msg){
	return msg == null || msg.trim().equals("")?true:false;
}

// callist - 날짜를 클릭하면 그날짜의 일정을 모두 보이게 하는 callist.jsp로 이동 시키는 함수
public String callist(int year, int month, int day){
	
	String s = "";
	
	s += String.format("<a href='%s?year=%d&month=%d&day=%d'>",
						"callist.jsp", year, month, day);
	s += String.format("%2d", day);
	s += "</a>";
	
	return s;
}

// 일정을 추가 하기 위해서 pen이미지를 클릭하면, calwrite.jsp로 이동시킬 함수
public String showPen(int year, int month, int day){
	
	String s = "";
	String url = "calendarwrite.jsp";
	String image = "<img src='image/pen.gif'>";
	
	s = String.format("<a href='%s?year=%d&month=%d&day=%d'>%s</a>",
								url, year, month, day, image);	
	return s;	
}

// 1 -> 01
public String two(String msg){
	return msg.trim().length()<2?"0"+msg:msg.trim();	
}

// 일정표시 -> 10자 이상이면, ...으로 표시되도록 하는 함수
public String dot3(String msg){
	String s = "";
	
	if(msg.length() >= 10){
		s = msg.substring(0, 10);
		s += "...";
	}else{
		s = msg.trim();
	}
	return s;
}

// 각 날짜 별로 테이블을 생성하는 함수
public String makeTable(int year, int month, int day, 
						List<CalendarDto> list){
	//달에 있는 일정들 중에 그 날에 해당되는것만 골라서 테이블로 쏴줌
	String s = "";
	String dates = (year+"") + two(month+"") + two(day+"");	// 20180827
	
	s = "<table>";
	s += "<col width='98'>";
	
	for(CalendarDto dto : list){
		
		if(dto.getRdate().substring(0, 8).equals(dates)){
			
			s += "<tr bgcolor='pink'>";
			s += "<td>";
			s += "<a href='calendardetail.jsp?seq=" + dto.getSeq() + "'>";
			s += "<font style='font-size:8; color:red'>";
			s += dot3(dto.getTitle());
			s += "</font>";
			s += "</a>";
			s += "</td>";
			s += "</tr>";			
		}			
	}	
	s += "</table>";
	
	return s;
}

%>

<h1 align="center">달력</h1>

<%
Calendar cal = Calendar.getInstance();
int tmpday = cal.get(Calendar.DATE);
cal.set(Calendar.DATE, 1);

String syear = request.getParameter("year");
String smonth = request.getParameter("month");

int year = cal.get(Calendar.YEAR);
if(!nvl(syear)){
	year = Integer.parseInt(syear);	
}

int month = cal.get(Calendar.MONTH) + 1;
if(!nvl(smonth)){
	month = Integer.parseInt(smonth);
}

if(month < 1){
	month = 12;
	year--;
}

if(month > 12){
	month = 1;
	year++;
}

cal.set(year, month-1, 1);	// 연월일 셋팅


int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);	// 요일 1 ~ 7

// <<
String pp = String.format("<a href='%s?year=%d&month=%d'><img src='image/left.gif'></a>", 
		"calendar.jsp", year-1, month);

// <
String p = String.format("<a href='%s?year=%d&month=%d'><img src='image/prec.gif'></a>", 
		"calendar.jsp", year, month-1);
// >
String n = String.format("<a href='%s?year=%d&month=%d'><img src='image/next.gif'></a>", 
		"calendar.jsp", year, month+1);

// >>
String nn = String.format("<a href='%s?year=%d&month=%d'><img src='image/last.gif'></a>", 
		"calendar.jsp", year+1, month);


//MemberDto user = (MemberDto)session.getAttribute("login");

CalendarDAOImpl dao = CalendarDAO.getInstance();

List<CalendarDto> list = dao.getCalendarList("111", year + two(month+ ""));


%>

<div align="center">

<table border="1">
<col width="100"><col width="100"><col width="100"><col width="100">
<col width="100"><col width="100"><col width="100">

<tr height="100">
<td colspan="7" align="center">

<%=pp %><%=p %>

<font color="black" style="font-size: 50">
<%=String.format("%d년&nbsp;&nbsp;%d월", year, month) %>
</font>

<%=n %><%=nn %>

</td>
</tr>

<tr height="100">
<td align="center">일</td>
<td align="center">월</td>
<td align="center">화</td>
<td align="center">수</td>
<td align="center">목</td>
<td align="center">금</td>
<td align="center">토</td>
</tr>

<tr height="100" align="left" valign="top">
<%
for(int i = 1; i < dayOfWeek; i++){ //처음에 빈칸들
	%>
		<td>&nbsp;</td>
	<%
}

int lastDay = cal.getActualMaximum(Calendar.DAY_OF_MONTH); 
for(int i = 1; i <= lastDay; i++){ //달에 있는 일수 만큼
	%>	
	
	<td><%=callist(year, month, i) %>&nbsp;<%=showPen(year, month, i) %>
	<%=makeTable(year, month, i, list) %>
	</td>	
	<%
	if((i + dayOfWeek - 1) % 7 == 0 && i != lastDay){//줄바꿈
		%>	
		</tr><tr height="100" align="left" valign="top">
		<%
	}	
}

for(int i = 0;i < (7 - (dayOfWeek + lastDay - 1)%7 )%7 ; i++){
	//                  마지막날 7로 나누고 남은거 
	%> 
	<td>&nbsp;</td>
	<%	
}
%>
</tr>
</table>
</div>

<br><br><br>
<script type='text/javascript'>

	$(document).ready(function() {
	
		var date = new Date();
		var d = date.getDate();
		var m = date.getMonth();
		var y = date.getFullYear();
		
		$('#calendar').fullCalendar({
			header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,basicWeek,basicDay'
			},
			editable: true,
			events: [
				
			]
		});
		
	});

</script>
<div id='calendar'></div>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</body>
</html>