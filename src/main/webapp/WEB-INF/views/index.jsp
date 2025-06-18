<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
    <style>
        /* 히어로 섹션 - 비디오 배경 */
        .hero-section {
            margin-top: 110px;
            position: relative;
            height: 100vh;
            min-height: 600px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* 비디오 배경 스타일 */
        .video-background {
            position: absolute;
            top: 50%;
            left: 50%;
            min-width: 100%;
            min-height: 100%;
            width: auto;
            height: auto;
            transform: translate(-50%, -50%);
            z-index: -2;
            object-fit: cover;
        }

        /* 비디오 오버레이 */
        .video-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(22, 45, 67, 0.4) 0%, rgba(22, 45, 67, 0.6) 100%);
            z-index: -1;
        }

        /* 히어로 콘텐츠 */
        .hero-content {
            position: relative;
            z-index: 1;
            text-align: center;
            color: white;
            max-width: 800px;
            padding: 0 20px;
            animation: fadeInUp 1s ease-out;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            padding: 8px 20px;
            border-radius: 50px;
            font-size: 16px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .badge .emoji {
            font-size: 20px;
        }

        .hero-title {
            font-size: 72px;
            font-weight: 700;
            line-height: 1.1;
            margin-bottom: 30px;
            text-shadow: 0 2px 20px rgba(0,0,0,0.2);
        }

        .hero-description {
            font-size: 24px;
            font-weight: 300;
            line-height: 1.5;
            margin-bottom: 50px;
            opacity: 0.95;
        }

        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 16px 40px;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
            display: inline-block;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: #162D43;
            color: white;
            box-shadow: 0 4px 15px rgba(22, 45, 67, 0.3);
        }

        .btn-primary:hover {
            background: #0f1f2f;
            transform: translateY(-2px);

        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.5);
            backdrop-filter: blur(10px);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: white;
            transform: translateY(-2px);
        }

        /* 로딩 화면 */
        .loading-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #162D43;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            transition: opacity 0.5s, visibility 0.5s;
        }

        .loading-screen.hidden {
            opacity: 0;
            visibility: hidden;
        }

        .loader {
            width: 50px;
            height: 50px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 48px;
            }

            .hero-description {
                font-size: 18px;
            }

            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
                max-width: 300px;
            }

        }

        /* 모바일에서 비디오 대체 이미지 */
        @media (max-width: 768px) and (hover: none) {
            .video-background {
                display: none;
            }

            .hero-section::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: -2;
            }
        }

        .hero-content {
            max-width: 600px;
        }

      /*  .hero h1 {
            font-size: 56px;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 24px;
            letter-spacing: -1px;
        }

        .hero p {
            font-size: 20px;
            margin-bottom: 40px;
            opacity: 0.9;
            line-height: 1.5;
        }*/



        /* Categories Section */
        .categories {
            padding: 80px 0;
            background: #f8f9fa;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .section-header {
            text-align: center;
            margin-bottom: 60px;
        }

        .section-title {
            font-size: 36px;
            font-weight: 700;
            color: #333;
            margin-bottom: 16px;
            letter-spacing: -0.5px;
        }

        .section-subtitle {
            font-size: 18px;
            color: #666;
            max-width: 600px;
            margin: 0 auto;
        }

        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
        }

        .category-card {
            background: white;
            border-radius: 16px;
            padding: 32px 24px;
            text-align: center;
            transition: all 0.3s;
            border: 1px solid #e5e5e5;
            cursor: pointer;
        }

        .category-card:hover {
            /* transform: translateY(-8px); */
            transform: translate(-5px, -5px) rotate(-1deg);
            box-shadow: 13px 13px 0 rgba(0,0,0,0.1);
            /* box-shadow: 0 20px 40px rgba(0,0,0,0.1); */
            border-color: #162D43;
        }

        .category-icon {
            width: 80px;
            height: 80px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 32px;
            font-weight: bold;
            color: white;
        }

        .category-icon.programming { background: linear-gradient(135deg, #162D43, #0f1f2f); }
        .category-icon.design { background: linear-gradient(135deg, #2a5a7b, #162D43); }
        .category-icon.business { background: linear-gradient(135deg, #4a7c9c, #162D43); }
        .category-icon.data { background: linear-gradient(135deg, #6a9ebd, #2a5a7b); }

        .category-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 12px;
            color: #333;
        }

        .category-desc {
            color: #666;
            font-size: 14px;
            line-height: 1.5;
        }

        /* Courses Section */
        .courses {
            padding: 80px 0;
        }

        .course-filters {
            display: flex;
            gap: 12px;
            margin-bottom: 40px;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 12px 20px;
            border: 1px solid #ddd;
            background: white;
            color: #666;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
            font-weight: 500;
        }

        .filter-btn.active, .filter-btn:hover {
            background: #162D43;
            color: white;
            border-color: #162D43;
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 32px;
        }

        .course-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            transition: all 0.3s;
            cursor: pointer;
            border: 1px solid #f0f0f0;
        }

        .course-card:hover {
            /* transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15); */
            transform: translate(-5px, -5px) rotate(-1deg);
            box-shadow: 13px 13px 0 rgba(0,0,0,0.1);
        }

        .course-image {
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, #162D43, #264058);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            font-weight: bold;
            position: relative;
        }

        .course-badge {
            position: absolute;
            top: 16px;
            left: 16px;
            background: rgba(255, 255, 255, 0.9);
            color: #162D43;
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .course-content {
            padding: 24px;
        }

        .course-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
            font-size: 14px;
            color: #666;
        }

        .course-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 12px;
            color: #333;
            line-height: 1.4;
        }

        .course-instructor {
            font-size: 14px;
            color: #666;
            margin-bottom: 16px;
        }

        .course-schedule {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 20px;
        }

        .schedule-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .schedule-row:last-child {
            margin-bottom: 0;
        }

        .schedule-label {
            color: #666;
        }

        .schedule-value {
            font-weight: 500;
            color: #333;
        }

        .course-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .course-price {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
        }

        .price-original {
            font-size: 14px;
            color: #999;
            text-decoration: line-through;
        }

        .price-current {
            font-size: 24px;
            font-weight: 700;
            color: #162D43;
        }

        .btn-enroll {
            background: #162D43;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-enroll:hover {
            background: #0f1f2f;
        }

        /* Stats Section */
        .stats {
            background: #333;
            color: white;
            padding: 60px 0;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 40px;
            text-align: center;
        }

        .stat-item {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .stat-number {
            font-size: 48px;
            font-weight: 800;
            color: #84b3d3;
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 16px;
            color: #ccc;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .section-title {
                font-size: 28px;
            }

            .course-grid {
                grid-template-columns: 1fr;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-up {
            animation: fadeInUp 0.6s ease-out;
        }
    </style>
<section>
<!-- 로딩 화면 -->
<div class="loading-screen" id="loadingScreen">
    <div class="loader"></div>
</div>

<!-- 히어로 섹션 with 비디오 배경 -->
<section class="hero-section">
    <!-- 비디오 배경 -->
    <video class="video-background" id="bgVideo" muted playsinline>
        <source src="${path}/resources/upload/main.mp4" type="video/mp4">
        <!-- 비디오를 지원하지 않는 브라우저를 위한 대체 -->
        Your browser does not support the video tag.
    </video>

    <!-- 비디오 오버레이 -->
    <div class="video-overlay"></div>

    <!-- 히어로 콘텐츠 -->
    <div class="hero-content">
        <div class="badge">
            <span class="emoji">🚀</span>
            <span>NEW 오프라인 강의</span>
        </div>

        <h1 class="hero-title">
            미래를 밝게 빛내는<br>
            오프라인 강의
        </h1>

        <p class="hero-description">
            업계 최고 전문가들과 함께하는 집중 교육 프로그램으로<br>
            당신의 커리어를 한 단계 업그레이드하세요
        </p>

        <div class="cta-buttons">
            <a href="#register" class="btn btn-primary">강의 둘러보기</a>
            <a href="https://open.kakao.com/o/scWgCCzh" class="btn btn-secondary">무료 상담 신청</a>
        </div>
    </div>
</section>


<!-- Categories -->
<section class="categories">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">분야별 강의</h2>
            <p class="section-subtitle">다양한 분야의 전문 강의를 통해 실무 능력을 향상시켜보세요</p>
        </div>
        <div class="category-grid">
            <div class="category-card" onclick="filterCourses('programming')">
                <div class="category-icon programming">💻</div>
                <h3 class="category-title">프로그래밍</h3>
                <p class="category-desc">웹개발, 앱개발, 데이터사이언스 등 최신 개발 기술을 배워보세요</p>
            </div>
            <div class="category-card" onclick="filterCourses('design')">
                <div class="category-icon design">🎨</div>
                <h3 class="category-title">디자인</h3>
                <p class="category-desc">UI/UX, 그래픽 디자인, 브랜딩까지 창의적 역량을 키워보세요</p>
            </div>
            <div class="category-card" onclick="filterCourses('business')">
                <div class="category-icon business">📊</div>
                <h3 class="category-title">비즈니스</h3>
                <p class="category-desc">마케팅, 기획, 경영 전략으로 비즈니스 역량을 강화하세요</p>
            </div>
            <div class="category-card" onclick="filterCourses('data')">
                <div class="category-icon data">📈</div>
                <h3 class="category-title">데이터 분석</h3>
                <p class="category-desc">빅데이터, AI, 머신러닝으로 데이터 전문가가 되어보세요</p>
            </div>
        </div>
    </div>
</section>

<!-- Courses -->
<section class="courses" id="courses">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">🔥인기 강의</h2>
            <p class="section-subtitle">검증된 커리큘럼과 전문 강사진이 함께하는 프리미엄 교육</p>
        </div>

        <div class="course-filters">
            <button class="filter-btn active" onclick="filterCourses('all')">전체</button>
            <button class="filter-btn" onclick="filterCourses('programming')">프로그래밍</button>
            <button class="filter-btn" onclick="filterCourses('design')">디자인</button>
            <button class="filter-btn" onclick="filterCourses('business')">비즈니스</button>
            <button class="filter-btn" onclick="filterCourses('data')">데이터분석</button>
        </div>

        <div class="course-grid">
            <!-- Course 1 -->
            <div class="course-card" data-category="programming">
                <div class="course-image">
                    <span class="course-badge">HOT</span>
                    React & Node.js
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>👨‍💻 프로그래밍</span>
                        <span>⭐ 4.9 (234)</span>
                    </div>
                    <h3 class="course-title">풀스택 웹개발 마스터 부트캠프</h3>
                    <p class="course-instructor">김개발 강사 · 네이버 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">12주 (120시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">평일반 19:00-22:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">강남 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.01</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩1,200,000</span>
                            <span class="price-current">₩890,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 2 -->
            <div class="course-card" data-category="design">
                <div class="course-image">
                    <span class="course-badge">NEW</span>
                    UI/UX Design
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>🎨 디자인</span>
                        <span>⭐ 4.8 (189)</span>
                    </div>
                    <h3 class="course-title">실무 UI/UX 디자인 완성 과정</h3>
                    <p class="course-instructor">박디자인 강사 · 카카오 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">8주 (64시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">주말반 10:00-18:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">홍대 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.05</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩980,000</span>
                            <span class="price-current">₩720,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 3 -->
            <div class="course-card" data-category="business">
                <div class="course-image">
                    Digital Marketing
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>📊 비즈니스</span>
                        <span>⭐ 4.7 (156)</span>
                    </div>
                    <h3 class="course-title">디지털 마케팅 전략 및 실무</h3>
                    <p class="course-instructor">최마케팅 강사 · 구글 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">6주 (48시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">화목 19:30-22:30</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">판교 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.08</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩750,000</span>
                            <span class="price-current">₩590,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 4 -->
            <div class="course-card" data-category="data">
                <div class="course-image">
                    <span class="course-badge">BEST</span>
                    Data Science
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>📈 데이터분석</span>
                        <span>⭐ 4.9 (298)</span>
                    </div>
                    <h3 class="course-title">Python 데이터 사이언스 부트캠프</h3>
                    <p class="course-instructor">이데이터 강사 · 삼성 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">10주 (100시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">주말집중반 09:00-18:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">강남 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.12</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩1,500,000</span>
                            <span class="price-current">₩1,190,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Stats -->
<section class="stats">
    <div class="container">
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-number">50,000+</div>
                <div class="stat-label">수강생</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">200+</div>
                <div class="stat-label">강의</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">95%</div>
                <div class="stat-label">만족도</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">80%</div>
                <div class="stat-label">취업률</div>
            </div>
        </div>
    </div>
</section>

<!-- Courses -->
<section class="courses" id="courses">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">마감임박 강의</h2>
            <p class="section-subtitle">검증된 커리큘럼과 전문 강사진이 함께하는 프리미엄 교육</p>
        </div>

        <div class="course-filters">
            <button class="filter-btn active" onclick="filterCourses('all')">전체</button>
            <button class="filter-btn" onclick="filterCourses('programming')">프로그래밍</button>
            <button class="filter-btn" onclick="filterCourses('design')">디자인</button>
            <button class="filter-btn" onclick="filterCourses('business')">비즈니스</button>
            <button class="filter-btn" onclick="filterCourses('data')">데이터분석</button>
        </div>

        <div class="course-grid">
            <!-- Course 1 -->
            <div class="course-card" data-category="programming">
                <div class="course-image">
                    <span class="course-badge">HOT</span>
                    React & Node.js
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>👨‍💻 프로그래밍</span>
                        <span>⭐ 4.9 (234)</span>
                    </div>
                    <h3 class="course-title">풀스택 웹개발 마스터 부트캠프</h3>
                    <p class="course-instructor">김개발 강사 · 네이버 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">12주 (120시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">평일반 19:00-22:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">강남 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.01</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩1,200,000</span>
                            <span class="price-current">₩890,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 2 -->
            <div class="course-card" data-category="design">
                <div class="course-image">
                    <span class="course-badge">NEW</span>
                    UI/UX Design
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>🎨 디자인</span>
                        <span>⭐ 4.8 (189)</span>
                    </div>
                    <h3 class="course-title">실무 UI/UX 디자인 완성 과정</h3>
                    <p class="course-instructor">박디자인 강사 · 카카오 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">8주 (64시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">주말반 10:00-18:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">홍대 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.05</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩980,000</span>
                            <span class="price-current">₩720,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 3 -->
            <div class="course-card" data-category="business">
                <div class="course-image">
                    Digital Marketing
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>📊 비즈니스</span>
                        <span>⭐ 4.7 (156)</span>
                    </div>
                    <h3 class="course-title">디지털 마케팅 전략 및 실무</h3>
                    <p class="course-instructor">최마케팅 강사 · 구글 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">6주 (48시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">화목 19:30-22:30</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">판교 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.08</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩750,000</span>
                            <span class="price-current">₩590,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>

            <!-- Course 4 -->
            <div class="course-card" data-category="data">
                <div class="course-image">
                    <span class="course-badge">BEST</span>
                    Data Science
                </div>
                <div class="course-content">
                    <div class="course-meta">
                        <span>📈 데이터분석</span>
                        <span>⭐ 4.9 (298)</span>
                    </div>
                    <h3 class="course-title">Python 데이터 사이언스 부트캠프</h3>
                    <p class="course-instructor">이데이터 강사 · 삼성 출신</p>

                    <div class="course-schedule">
                        <div class="schedule-row">
                            <span class="schedule-label">기간</span>
                            <span class="schedule-value">10주 (100시간)</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">일시</span>
                            <span class="schedule-value">주말집중반 09:00-18:00</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">장소</span>
                            <span class="schedule-value">강남 캠퍼스</span>
                        </div>
                        <div class="schedule-row">
                            <span class="schedule-label">시작일</span>
                            <span class="schedule-value">2025.07.12</span>
                        </div>
                    </div>

                    <div class="course-footer">
                        <div class="course-price">
                            <span class="price-original">₩1,500,000</span>
                            <span class="price-current">₩1,190,000</span>
                        </div>
                        <button class="btn-enroll">수강 신청</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
</section>

<script>
    // 비디오 자동 재생 및 제어
    document.addEventListener('DOMContentLoaded', function() {
        const video = document.getElementById('bgVideo');
        const loadingScreen = document.getElementById('loadingScreen');

        // 비디오 설정
        video.autoplay = true;
        video.loop = false; // 반복 재생 비활성화

        // 비디오가 준비되면 재생
        video.addEventListener('canplay', function() {
            video.play().then(() => {
                // 로딩 화면 숨기기
                setTimeout(() => {
                    loadingScreen.classList.add('hidden');
                }, 500);
            }).catch(error => {
                // 자동 재생이 차단된 경우
                console.log('자동 재생이 차단되었습니다:', error);
                loadingScreen.classList.add('hidden');
            });
        });

        // 비디오가 끝나면 마지막 프레임에서 정지
        video.addEventListener('ended', function() {
            // 비디오가 끝나면 마지막 프레임에서 멈춤
            video.pause();
            // 마지막 프레임 유지를 위해 currentTime을 약간 뒤로
            video.currentTime = video.duration - 0.1;
        });

        // 비디오 로드 에러 처리
        video.addEventListener('error', function() {
            console.error('비디오 로드 실패');
            loadingScreen.classList.add('hidden');
        });

        // 스크롤 시 비디오 페이드 효과 (선택사항)
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const heroSection = document.querySelector('.hero-section');
            const opacity = 1 - (scrolled / 800);

            if (opacity >= 0) {
                heroSection.style.opacity = opacity;
            }
        });

        // 모바일 감지 및 비디오 처리
        function isMobile() {
            return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        }

        // 모바일에서는 데이터 절약을 위해 비디오 제거
        if (isMobile()) {
            video.remove();
            loadingScreen.classList.add('hidden');
        }
    });

    // 페이지 로드 완료 후 로딩 화면 제거 (백업)
    window.addEventListener('load', function() {
        setTimeout(() => {
            document.getElementById('loadingScreen').classList.add('hidden');
        }, 2000);
    });

    // 강의 필터링 함수
    function filterCourses(category) {
        const cards = document.querySelectorAll('.course-card');
        const buttons = document.querySelectorAll('.filter-btn');

        // 모든 버튼에서 active 클래스 제거
        buttons.forEach(btn => btn.classList.remove('active'));

        // 클릭된 버튼에 active 클래스 추가
        event.target.classList.add('active');

        // 카드 필터링
        cards.forEach(card => {
            if (category === 'all' || card.dataset.category === category) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>