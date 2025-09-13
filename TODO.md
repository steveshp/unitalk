# Unitalk 개발 할 일 목록

## ✅ 완료된 작업

### 1. 기본 기능 구현
- [x] API 키 설정 파일 구조 생성
- [x] 오디오 스트림 오류 해결 (웹 환경 최적화)
- [x] 모바일 UI 반응형 디자인 구현
- [x] Firebase 인증 시스템 구현
  - [x] 이메일/비밀번호 로그인
  - [x] 익명 로그인
  - [x] 회원가입 기능
- [x] Firebase Realtime Database 연동
  - [x] 사용자별 API 키 저장/조회
  - [x] 사용자 설정 관리

### 2. 웹앱 최적화
- [x] Flutter Web 빌드 설정
- [x] 모바일 뷰포트 대응 (390x844)
- [x] 다크 테마 UI 구현

## 📋 진행 예정 작업

### 1. Firebase 설정 (우선순위: 높음)
- [ ] Firebase 프로젝트 생성 및 설정
  - [ ] Firebase Console에서 새 프로젝트 생성
  - [ ] Authentication 서비스 활성화
  - [ ] Realtime Database 규칙 설정
  - [ ] 웹앱 등록 및 설정 키 획득
- [ ] 실제 Firebase 설정 적용
  - [ ] `lib/main.dart`의 FirebaseOptions 실제 값으로 교체
  - [ ] 환경 변수로 민감한 정보 관리

### 2. API 키 관리 기능 (우선순위: 높음)
- [ ] 설정 페이지 UI 구현
  - [ ] API 키 입력/수정 폼
  - [ ] API 키 유효성 검증
  - [ ] 테스트 버튼 추가
- [ ] API 키 암호화 저장
- [ ] API 키별 사용량 추적

### 3. 오디오 녹음 개선 (우선순위: 중간)
- [ ] 웹 오디오 녹음 완전 구현
  - [ ] MediaRecorder API 최적화
  - [ ] 오디오 포맷 변환 (WebM to WAV)
  - [ ] 청크 단위 스트리밍 녹음
- [ ] 녹음 품질 설정 옵션
- [ ] 배경 소음 제거 기능

### 4. 음성 인식 기능 확장 (우선순위: 중간)
- [ ] 실시간 음성 인식 (스트리밍)
- [ ] 다국어 자동 감지
- [ ] 사용자 정의 단어 사전
- [ ] 음성 명령 기능

### 5. 번역 기능 (우선순위: 낮음)
- [ ] Google Translate API 연동
- [ ] 실시간 번역 표시
- [ ] 번역 히스토리 저장
- [ ] 번역 언어 쌍 설정

### 6. PWA 기능 구현 (우선순위: 낮음)
- [ ] Service Worker 설정
- [ ] 오프라인 모드 지원
- [ ] 설치 가능한 웹앱 설정
- [ ] 푸시 알림 기능

### 7. UI/UX 개선
- [ ] 로딩 애니메이션 추가
- [ ] 터치 제스처 지원
- [ ] 접근성 개선 (ARIA 레이블)
- [ ] 라이트 테마 옵션
- [ ] 언어별 UI 번역

### 8. 성능 최적화
- [ ] 코드 스플리팅
- [ ] 이미지/자산 최적화
- [ ] 캐싱 전략 구현
- [ ] 번들 크기 최소화

### 9. 테스트 및 품질 관리
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 구현
- [ ] E2E 테스트 설정
- [ ] 에러 추적 시스템 (Sentry)

### 10. 배포 준비
- [ ] 환경별 설정 분리 (개발/운영)
- [ ] CI/CD 파이프라인 구성
- [ ] 도메인 설정 및 HTTPS
- [ ] 모니터링 대시보드

## 🐛 알려진 이슈

1. **오디오 녹음**: 웹에서 스트림 녹음 미구현 (현재 빈 데이터 반환)
2. **브라우저 호환성**: Safari에서 WebM 포맷 제한
3. **API 키 보안**: 클라이언트 사이드 저장 보안 강화 필요
4. **메모리 누수**: 장시간 녹음 시 메모리 사용량 증가

## 📱 모바일 브라우저 테스트 체크리스트

- [ ] Chrome (Android)
- [ ] Safari (iOS)
- [ ] Samsung Internet
- [ ] Firefox Mobile
- [ ] Edge Mobile

## 🚀 배포 옵션

1. **Vercel**: 간단한 정적 호스팅
2. **Firebase Hosting**: Firebase 서비스와 통합
3. **Netlify**: CI/CD 통합 용이
4. **GitHub Pages**: 무료 호스팅

## 📝 참고사항

- Firebase 프로젝트 설정 가이드: https://firebase.google.com/docs/web/setup
- Whisper API 문서: https://platform.openai.com/docs/guides/speech-to-text
- Flutter Web 최적화: https://docs.flutter.dev/platform-integration/web/building

---

마지막 업데이트: 2025-09-13