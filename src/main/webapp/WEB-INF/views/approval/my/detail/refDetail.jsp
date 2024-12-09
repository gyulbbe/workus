<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ include file="/WEB-INF/views/common/tags.jsp" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/WEB-INF/views/common/common.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/approval.css">
    <script src="/resources/js/approval.js"></script>
    <!-- Include the Quill library -->
    <link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
    <c:set var="menuTitle" value="열람건"/>
    <title>workus ㅣ 결재 ${menuTitle}</title>
</head>
<body>
<div id="divWrapper">
    <div id="divContents">
        <c:set var="menu" value="approval"/>
        <%@ include file="/WEB-INF/views/common/header.jsp" %>
        <section class="verticalLayoutFixedSection">
            <%@ include file="/WEB-INF/views/common/nav.jsp" %>
            <c:set var="lnb" value="myRefList"/>
            <div class="lnb">
                <ul class="list1">
                    <li class="${lnb eq 'signOff' ? 'on' : '' }"><a
                            href="${pageContext.request.contextPath}/approval/form-list">결재 요청하기</a></li>
                    <li class="${lnb eq 'myReqList' ? 'on' : '' }"><a
                            href="${pageContext.request.contextPath}/approval/my/reqList">요청 내역</a></li>
                </ul>
                <sec:authorize access="hasAnyRole('ROLE_ADMIN', 'ROLE_MANAGER', 'ROLE_LEADER')">
                    <div class="approvalDepth accordion" id="accordionPanelsStayOpenExample">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse"
                                        data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="false"
                                        aria-controls="panelsStayOpen-collapseOne">
                                    결재함
                                </button>
                            </h2>
                            <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <ul class="list2 myAtdList">
                                        <sec:authorize access="hasAnyRole('ROLE_ADMIN', 'ROLE_MANAGER')">
                                            <li class="${lnb eq 'myWaitList' ? 'on' : '' }"><a
                                                    href="${pageContext.request.contextPath}/approval/my/waitList">대기건</a>
                                            </li>
                                            <li class="${lnb eq 'myEndList' ? 'on' : '' }"><a
                                                    href="${pageContext.request.contextPath}/approval/my/endList">종결건</a>
                                            </li>
                                            <li class="${lnb eq 'myDelList' ? 'on' : '' }"><a
                                                    href="${pageContext.request.contextPath}/approval/my/backList">반려건</a>
                                            </li>
                                        </sec:authorize>
                                        <sec:authorize access="hasRole('ROLE_LEADER')">
                                            <li class="${lnb eq 'myRefList' ? 'on' : '' }"><a
                                                    href="${pageContext.request.contextPath}/approval/my/refList">열람건</a>
                                            </li>
                                        </sec:authorize>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </sec:authorize>
            </div>
            <main>
                <h3 class="title1">
                    ${menuTitle}
                </h3>
                <div id="apvListW" class="containerW">
                    <div class="tableW mgt40">
                        <table class="table tableStyle">
                            <tbody>
                                <tr>
                                    <th class="table-active title">신청 기본 정보</th>
                                    <td colspan="5" class="text-start">
                                        [${refByNo.categoryName}] ${refByNo.title}
                                    </td>
                                </tr>
                                <tr>
                                    <th class="table-active">요청 상태</th>
                                    <td colspan="2" class="text-start">
                                        <c:choose>
                                            <c:when test="${refByNo.status == 'pending'}">
                                                <span class="badge text-bg-primary">승인 대기</span>
                                            </c:when>
                                            <c:when test="${refByNo.status == 'rejected'}">
                                                <span class="badge text-bg-danger">반려</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge border bg-secondary">처리 완료</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <th class="table-active">요청일</th>
                                    <td colspan="2" class="text-start">
                                        <fmt:formatDate value="${refByNo.createdDate }"/>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <table class="table tableStyle">
                            <tbody>
                            <c:forEach var="option" items="${refByNo.optionTexts}">
                                <tr>
                                    <th class='table-active title'>${option.textName}</th>
                                    <td colspan='5' class='text-start'>${option.textValue}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${not empty refByNo.reason}">
                                <tr>
                                    <th class="table-active title">${refByNo.reasonTitle}</th>
                                    <td colspan='5' class='text-start'>${refByNo.reason}</td>
                                </tr>
                            </c:if>
                            <c:if test="${not empty refByNo.commonText}">
                                <c:if test="${refByNo.categoryNo == 800}">
                                    <tr>
                                        <th colspan='6' class='table-active'>
                                            양식
                                        </th>
                                    </tr>
                                    <tr class="editorArea">
                                        <td colspan='6' class='text-start'>
                                            <div id="editor${refByNo.no}">${refByNo.commonText}</div>
                                            <!-- 스마트 에디터 관련 스크립트 추가 -->
                                        </td>
                                    </tr>
                                </c:if>
                                <c:if test="${refByNo.categoryNo != 800}">
                                    <tr>
                                        <th class="table-active title">기타 사항</th>
                                        <td colspan='5' class='text-start'>${refByNo.commonText}</td>
                                    </tr>
                                </c:if>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                    <c:choose>
                        <c:when test="${refByNo.status != 'pending'}">
                            <c:when test="${refByNo.status == 'completed'}">
                                <div class="additionalW">
                                    <p class="userInfoHeader">결재자 정보
                                    </p>
                                    <ul class="userInfoW">
                                        <li class="d-flex align-items-center">
                                            <img src="/resources/images/userIcon.png" alt="결재자 이미지"/>
                                            <div class="userInfo">
                                                <p class="name">강태오 <span class="position">부장</span></p>
                            </c:when>
                            <c:when test="${refByNo.status == 'rejected'}">
                                                <p class="status">반려</p>
                                                <p class="status">사유 : </p>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </c:when>
                        </c:when>
                    </c:choose>
                </div>
            </main>
        </section>
    </div>
</div>
<script>
    if(${refByNo.categoryNo} === 800) {
        // Quill 에디터 초기화
        var quill = new Quill('#editor${refByNo.no}', {
            theme: 'snow',
            modules: {
                "toolbar": false
            }
        });
        // disabled 처리
        quill.enable(false);
        // XSS 방지를 위한 HTML 이스케이프
        let commonText = "${fn:escapeXml(refByNo.commonText)}";
        // Quill의 clipboard 모듈을 사용하여 HTML 삽입
        let range = quill.getSelection();
        quill.clipboard.dangerouslyPasteHTML(range.index, commonText);
    }
</script>
</body>
</html>