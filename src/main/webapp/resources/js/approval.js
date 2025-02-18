$(function () {
    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ 공휴일 OPEN API ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */
    const serviceKey = 'A7%2FHaEQe1yP2IrM2iyJqZyrLs9SFLwZ788isUppVC7woA1J7J0n316aNTU7RL7B1GJUhjQDHpXhwBq7ud7u14A%3D%3D'
    /* Javascript 샘플 코드 */

    var xhr = new XMLHttpRequest();
    var url = 'http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo'; /*URL*/
    var queryParams = '?' + encodeURIComponent('serviceKey') + '=' + serviceKey; /*Service Key*/
    queryParams += '&' + encodeURIComponent('numOfRows') + '=' + encodeURIComponent('30'); /* 임의의 수 */
    queryParams += '&' + encodeURIComponent('solYear') + '=' + encodeURIComponent('2024'); /**/
    queryParams += '&' + encodeURIComponent('_type') + '=' + encodeURIComponent('json'); /**/
    xhr.open('GET', url + queryParams);
    xhr.onreadystatechange = function () {
        if (this.readyState == 4) {
            parseJSON(this.responseText);
        }
    };

    xhr.send('');

    let locdateArray = []; // locdate를 저장할 배열
    function parseJSON(jsonText) {
        let jsonObj = JSON.parse(jsonText);
        let items = jsonObj.response.body.items.item; // items의 item 배열에 접근

        // 각 item에 대해 locdate를 추출하고 요일을 확인
        for (let item of items) {
            if (item && item.locdate) { // item과 locdate가 존재하는지 확인
                // locdate의 요일 확인
                let date = new Date(item.locdate.toString().replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3')); // locdate를 YYYY-MM-DD 형식으로 변환
                let dayOfWeek = date.getDay(); // 요일 숫자 (0: 일요일, 1: 월요일, ..., 6: 토요일)

                // 토요일(6)과 일요일(0) 제외
                if (dayOfWeek !== 0 && dayOfWeek !== 6) {
                    locdateArray.push(item.locdate); // locdate를 배열에 추가
                }
            }
        }
        return locdateArray; // 최종적으로 주중 날짜만 포함된 locdateArray 반환
    }

    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ // 공휴일 OPEN API ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */

// dayTotal count (API + 함수 사용)
    let totalTime = 0;
    $('#apvFromDate').on("change", function () {
        totalTime = 0;
        let nowFromDate = $(this).val();
        $('#apvToDate').attr('min', nowFromDate).val(nowFromDate);
    });

    $('#apvToDate').on("change", function () {
        totalTime = 0;
        let fromDateStr = $('#apvFromDate').val();
        let toDateStr = $('#apvToDate').val();

        // Date 객체를 한 번만 생성
        let fromDate = new Date(fromDateStr);
        let toDate = new Date(toDateStr);

        // 주중과 주말을 구분하기 위한 상수
        const WEEKDAY_START = 1; // 월요일
        const WEEKDAY_END = 5;   // 금요일

        // 날짜 계산을 위한 변수
        let currentDate = new Date(fromDate);

        calculateWeekdays(fromDate, toDate, locdateArray);

        $('.dayTotal').html(totalTime);
    });

// 날짜 범위 내 주중 날짜 계산
    function calculateWeekdays(startDate, endDate, locdateArray) {
        let currentDate = new Date(startDate);
        let toDate = new Date(endDate);

        // locdateArray를 Set으로 변환하여 조회 성능 향상
        let holidaySet = new Set(locdateArray.map(date => date.toString()));

        while (currentDate <= toDate) {
            let dayOfWeek = currentDate.getDay();

            // 주말 및 공휴일 제외
            let locdateString = currentDate.toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD 형식으로 변환
            let tf = holidaySet.has(locdateString);

            if (dayOfWeek >= 1 && dayOfWeek <= 5 && !holidaySet.has(locdateString)) { // 월~금 (1~5), 공휴일 제외
                totalTime++;
            }

            // 다음 날짜로 이동
            currentDate.setDate(currentDate.getDate() + 1);
        }
        return totalTime; // 총 주중 날짜 수 반환
    }
})