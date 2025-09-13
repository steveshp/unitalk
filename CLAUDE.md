# CLAUDE.md

이 파일은 이 저장소에서 코드 작업을 할 때 Claude Code (claude.ai/code)에 대한 안내를 제공합니다.

## 중요: 언어 설정
**모든 응답, 설명, 주석은 반드시 한글로 작성합니다. 코드 자체는 영어로 유지하되, 코드에 대한 설명이나 사용자와의 모든 대화는 한글로 진행합니다.**

## 프로젝트 개요

Unitolk는 **웹 브라우저에서만 실행되는 Flutter 웹 애플리케이션**입니다. 모바일 앱이 아닌 **순수 웹앱**으로, Whisper AI를 사용하여 실시간 음성-텍스트 변환을 수행합니다. 브라우저에서 직접 오디오를 캡처하고, Whisper API 제공업체(Lemonfox 또는 OpenAI)로 전송한 후, 다국어 지원과 함께 변환 결과를 표시합니다.

### 🌐 웹앱 전용 프로젝트
- **플랫폼**: Flutter Web (모바일/데스크톱 앱 아님)
- **실행 환경**: 웹 브라우저 (Chrome 권장)
- **배포 방식**: 정적 웹 호스팅 (Vercel, Netlify, Firebase Hosting 등)
- **접근 방법**: URL을 통한 직접 접근

## 개발 명령어

### 웹앱 실행 (웹 전용)
```bash
# Chrome 브라우저에서 개발 모드 실행 (필수)
flutter run -d chrome

# 특정 포트로 웹 서버 실행
flutter run -d chrome --web-port=8080

# 프로덕션용 웹앱 빌드
flutter build web

# HTML 렌더러로 빌드 (더 작은 파일 크기)
flutter build web --web-renderer html

# CanvasKit 렌더러로 빌드 (더 나은 성능)
flutter build web --web-renderer canvaskit

# 빌드된 웹앱 로컬 테스트
cd build/web
python3 -m http.server 8000
```

### 코드 품질 및 테스트
```bash
# 코드 문제 분석
flutter analyze

# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/widget_test.dart

# 코드 포맷팅
dart format lib/

# 의존성 확인
flutter pub outdated
flutter pub upgrade
```

### 의존성 관리
```bash
# 의존성 설치
flutter pub get

# 클린 후 재설치
flutter clean
flutter pub get
```

## 아키텍처 개요

### 핵심 서비스 아키텍처
애플리케이션은 명확한 관심사 분리를 가진 서비스 기반 아키텍처를 사용합니다:

- **AudioService** (`lib/data/services/audio_service.dart`): Flutter의 record 패키지를 통해 Web Audio API를 사용하여 웹 오디오 녹음을 처리합니다. 녹음 상태, 진폭 모니터링을 관리하고 웹 호환성을 위한 Uint8List 오디오 데이터를 생성합니다.

- **WhisperService** (`lib/data/services/whisper_service.dart`): 폴백 지원이 있는 프로바이더 패턴을 구현합니다. 기본 프로바이더는 Lemonfox (3시간당 $0.50로 저렴)이며, OpenAI를 폴백으로 사용합니다 (3시간당 $1.08). 두 프로바이더 모두 동일한 WhisperProvider 인터페이스를 구현합니다.

### 상태 관리 패턴
반응형 상태 관리를 위해 GetX를 사용합니다:

- **AudioController** (`lib/presentation/controllers/audio_controller.dart`): 오디오 녹음 상태, 변환 결과 및 UI 업데이트를 관리하는 중앙 컨트롤러입니다. AudioService와 WhisperService 간의 조정을 담당합니다.

- Observable 상태에는 녹음 상태, 진폭 레벨, 지속 시간, 변환 결과 및 오류 메시지가 포함됩니다.

### 웹 오디오 구현 (웹앱 특화)
이 웹앱은 브라우저 환경에 맞춘 특별한 오디오 처리를 구현합니다:

- **메모리 기반 녹음**: 파일 시스템 접근이 제한된 브라우저를 위해 Uint8List로 메모리에서 직접 처리
- **Web Audio API 활용**: 브라우저의 네이티브 오디오 API를 Flutter와 연결
- **16kHz 모노 설정**: Whisper AI에 최적화된 오디오 포맷
- **실시간 스트리밍**: 오디오 청크를 실시간으로 처리하여 메모리 효율성 확보
- **브라우저 권한 관리**: getUserMedia API를 통한 마이크 권한 요청 및 처리

### API 구성
API 키는 `lib/core/constants/api_config.dart`에 중앙 집중화되어 있습니다. 실제 API 키를 커밋하지 마십시오 - 커밋에는 플레이스홀더 값을 사용하세요.

## 중요한 구현 세부사항

### 웹 플랫폼 특성
- 브라우저 호환성을 위해 `record_web` 패키지를 사용한 오디오 녹음
- 'audio/webm;codecs=opus' 형식의 MediaRecorder API
- 브라우저에서 마이크 액세스를 위해 HTTPS 필요
- Safari는 제한된 WebM 지원 - 폴백 형식이 필요할 수 있음

### Whisper API 통합
- 두 프로바이더 모두 오디오 바이트가 포함된 multipart form data 사용
- 타임아웃 설정: 연결 30초, 수신 60초
- 응답 형식: 텍스트, 언어 및 선택적 신뢰도 점수가 포함된 JSON
- 폴백 메커니즘은 기본 프로바이더 실패 시 자동으로 보조 프로바이더 시도

### UI 상태 업데이트
- 모든 UI 업데이트는 GetX observables를 통해 흐름
- 녹음 중 100ms 간격으로 파형 시각화 업데이트
- 처리 즉시 변환 결과 표시
- UI에 사용자 친화적인 메시지로 오류 상태 표시

## 프로젝트별 패턴

### 위젯 구조
- 페이지는 GetX 컨트롤러와 함께 stateless 위젯 사용
- flutter_animate 패키지를 사용한 애니메이션 구현
- Color(0xFF1A1A2E)를 기본 배경으로 하는 다크 테마
- 둥근 모서리 일관된 사용 (BorderRadius.circular(20))

### 오류 처리
- 서비스 레이어는 debugPrint로 오류를 캐치하고 로그
- 컨트롤러는 UI 표시를 위해 오류 observables 업데이트
- API 복원력을 위한 폴백 프로바이더
- UI에 사용자 친화적인 오류 메시지 표시

### 성능 고려사항
- 메모리 문제 방지를 위한 스트리밍용 오디오 청킹
- 100ms 간격으로 제한된 진폭 모니터링
- 효율성을 위해 ListView.builder를 사용한 변환 표시
- 가능한 경우 하드웨어 가속을 사용한 애니메이션

## 웹앱 배포 방법

### 정적 호스팅 서비스 배포
```bash
# Vercel 배포
vercel deploy build/web

# Netlify 배포
netlify deploy --dir=build/web --prod

# Firebase Hosting 배포
firebase deploy --only hosting

# GitHub Pages 배포 (저장소 설정 필요)
# build/web 내용을 gh-pages 브랜치에 푸시
```

### 웹 서버 요구사항
- **HTTPS 필수**: 마이크 접근을 위해 보안 연결 필요
- **CORS 설정**: API 호출을 위한 Cross-Origin 설정
- **MIME 타입**: WASM 파일을 위한 application/wasm 지원

## 알려진 문제 및 제한사항 (웹앱 관련)

1. **브라우저 호환성**
   - Chrome/Edge: 완벽 지원
   - Firefox: 지원 (일부 오디오 코덱 제한)
   - Safari: WebM 형식 제한으로 부분 지원
   - 모바일 브라우저: 백그라운드 녹음 불가

2. **웹 플랫폼 제약**
   - 파일 시스템 직접 접근 불가 (브라우저 보안 정책)
   - 백그라운드 처리 제한
   - 오프라인 모드 제한적 지원 (PWA 구현 필요)

3. **미구현 기능**
   - Firebase 실시간 동기화
   - Google Translate 번역 기능
   - PWA (Progressive Web App) 기능
   - 오프라인 모드

4. **설정 필요 사항**
   - API 키 수동 구성 필요
   - HTTPS 환경 필수
   - Chrome 브라우저 권장