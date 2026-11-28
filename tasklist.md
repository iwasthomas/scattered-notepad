# 사전 시험 Tasklist (2026-11-23)

목적: 브리프의 미검증 3건(`pg_trgm`·한글 검색, 가입 차단, PWA 세션 유지)을 실제로 시험하고, PRD 작성 전에 Supabase·Vercel 환경을 준비합니다.

여러 기기(개인 PC, 노트북, 모바일)에서 이어 작업할 때는 git 저장소(`main` 또는 작업 브랜치)가 기준입니다. 세션을 닫기 전에 커밋하고 푸시합니다.

보안 원칙: DB 비밀번호, 액세스 토큰, 서비스 키는 채팅에 붙여 넣지 않습니다. 로그인은 아래 `!` 명령으로 이 세션 안에서 하고, 키는 환경 변수나 `.env` 파일에만 둡니다.

## A. 사용자가 직접 할 일

- [x] **A1. Supabase 계정과 프로젝트 만들기** (2026-11-23 완료) (https://supabase.com/dashboard)
  - 계정이 없으면 가입합니다.
  - New project: 이름 예) `scattered-notepad`, Region은 가까운 곳(Seoul `ap-northeast-2` 권장), DB 비밀번호는 직접 정하고 비밀번호 관리자에 저장합니다.
  - 완료 후 알려 주세요. 프로젝트 이름만 알려 주시면 됩니다(키·비밀번호는 알려 주지 마세요).
- [x] **A2. Supabase CLI 로그인** (2026-11-25 확인 완료)
  - 이 세션에서 `! npx supabase login` 을 실행하고 브라우저에서 승인합니다.
- [x] **A3. Vercel 계정 만들기와 CLI 로그인** (2026-11-25 확인 완료)
  - 계정이 없으면 https://vercel.com 에서 Hobby 플랜으로 가입합니다.
  - 이 세션에서 `! npx vercel login` 을 실행하고 브라우저에서 승인합니다.
  - Hobby는 비상업·개인 용도 제한이 있습니다. 개인 메모 용도로 쓰는 것이 맞는지는 본인 판단입니다.
- [ ] **A4. 실기기 PWA 시험(B5 이후)** (진행 중: 2026-11-25 기준 세션 유지 양호, 7일째는 약 11-30)
  - Android와 iPhone에서 제가 배포한 시험 URL을 열고, 홈 화면에 추가한 뒤 며칠 동안 로그인 유지 여부를 기록합니다.
  - 기록할 것: 설치 방법, 첫 실행 시간(체감), 1일·3일·7일 뒤 로그인 유지 여부.
- [x] **A5. 로그인 계정 만들기(B3 이후)** (2026-11-23 완료, 사용자 1명·확인 완료)
  - 제가 가입 차단을 켠 뒤, Supabase 대시보드 Authentication > Users에서 본인 이메일로 사용자를 직접 추가합니다(비밀번호는 직접 입력).

## B. 제가 할 일 (A1~A3 완료 후)

- [x] **B1.** `npx supabase projects list`로 프로젝트 연결 확인, 작업 폴더 `C:\mygit\pjy-dir`에 `supabase init`과 `link` (2026-11-23 완료, ref `gzytkfonulyhewuucjsi`, Seoul)
- [x] **B2. 한글 검색 시험** (2026-11-23 통과. `pg_trgm` 설치 가능, 정규화 컬럼 ILIKE로 모든 케이스 통과. 시험 테이블 `public.spike_memos`는 B4 후 B8에서 정리)
  - `create extension pg_trgm;` 가능 여부 확인
  - 시험 테이블에 한글 메모 20건 이상 입력: "리포트클립로", "리포트 클립", NFD로 입력된 한글, 2글자 검색어, 조사가 붙은 단어
  - 정규화 컬럼(소문자, NFC, 공백 제거)에 `ILIKE '%리포트클립%'`가 "리포트클립로"와 "리포트 클립"를 모두 찾는지 확인
  - `pg_trgm` 인덱스가 있을 때와 없을 때 실행 계획을 비교
- [x] **B3. 가입 차단**: (2026-11-23 통과) `supabase config pull`로 원격 설정을 가져온 뒤 `enable_signup = false`만 바꿔 push. 가입 API가 `signup_disabled`(HTTP 422)로 거부됨. 원격과 로컬 설정 차이 0.
- [x] **B4. RLS 시험**: (2026-11-23 통과) 비로그인(anon) 읽기·쓰기·삭제 모두 `permission denied`(401). 로그인 사용자 시뮬레이션: 소유자 24건 조회, 다른 사용자 0건·남의 user_id로 쓰기 거부·남의 행 삭제 0건. **발견: 이 프로젝트는 새 테이블에 `anon`·`authenticated` 권한이 기본으로 없어서, 앱 테이블마다 `GRANT ... TO authenticated`를 명시해야 함.**
- [x] **B5. PWA 시험 페이지 배포**: (2026-11-23 배포 완료) https://scattered-notepad-spike.vercel.app — 소스는 `C:\mygit\pjy-dir\scattered-notepad-spike\`, Git 없이 `vercel deploy --prod`로 배포. manifest·service worker·아이콘·로그인·메모 저장 포함, `anon` 공개 키만 사용. 실제 로그인·저장 확인과 세션 유지 기록은 A4(사용자)에서 진행.
- [ ] **B6. keep-alive 시험** (**2026-11-28: 11-26 이후 cron 자동 실행 기록 확인 필요. Vercel 로그는 PC 세션이나 대시보드에서 확인**) (2026-11-25 수동 호출 통과: `public.keepalive()` RPC와 `/api/keepalive`가 DB 시각을 반환하고 Vercel 함수 로그에 기록됨. cron `0 3 * * *` 등록 확인. **남음: cron의 첫 자동 실행 기록을 11-26 03:00 UTC(한국 시간 12:00) 이후 확인.** `keepalive()` 함수는 슬라이스 0에서 계속 쓰므로 B8에서 지우지 않음): Vercel cron(하루 1회)이 Supabase에 실제 DB 쿼리를 보내는 함수를 호출하는지 확인
- [x] **B7. 내보내기 시험**: (2026-11-25 통과) 원본 29건과 복원본 29건의 행 내용 해시가 일치하고, `pg_trgm` 인덱스·RLS 정책도 복원됨. 임시 스키마 `restore_test`는 삭제 완료. **발견: `supabase db dump`는 Docker가 필요한데 이 PC에는 없어서 PostgreSQL 17 클라이언트를 설치하고 `pg_dump`로 대신함. 직접 연결 주소(`db.<ref>.supabase.co`)는 IPv6 전용이라 풀러(`aws-0-ap-northeast-2.pooler.supabase.com`, 사용자 `postgres.<ref>`)로 접속함.** 덤프 파일은 `backup/`에 있음(git 제외). DB 비밀번호는 `C:\mygit\pjy-dir\.env`의 `PGPASSWORD`에 있음(git 제외, 메모장으로 저장하면 줄 끝 `\r`이 붙으므로 읽을 때 제거해야 함)
- [ ] **B8. 정리** (2026-11-25 진행: 브리프의 "미검증" 반영 완료. 삭제는 A4·B6 확인 뒤로 보류): 시험 테이블·페이지 삭제 여부를 확인받고 결과를 브리프의 "미검증" 3건에 반영
  - 삭제 후보: `public.spike_memos` 테이블, 시험 페이지 `scattered-notepad-spike`(Vercel 프로젝트와 폴더), `backup/`(필요하면 보관). **삭제 전에 사용자에게 다시 확인합니다.**
  - **`public.keepalive()`는 지우지 않습니다.** 슬라이스 0의 접속 유지가 계속 씁니다. 단, 시험 페이지가 `anon` 키로 이 함수를 부르고 있으므로, `anon` 권한 회수는 시험 페이지를 없앤 뒤(또는 새 앱 cron이 돌기 시작한 뒤)에 합니다.
  - DB 비밀번호를 평문 `.env`에 한동안 두었으므로, 시험이 끝나면 Supabase 대시보드에서 재설정하고 `.env`를 갱신합니다.

## D. egm 설계 진행 (2026-11-25)

설계 문서: `docs/designs/scattered-notepad.md`. 입력 문서: `concepts_brief.md`.

- [x] **D1. brainstorm**: `concepts_brief.md` 작성(7개 관점 리뷰 포함)
- [x] **D2. draft**: `/egm:egm-draft` 완료. 모순 2건 해소(iOS도 MVP 지원 대상, PRD·ROADMAP·용어집은 별도 문서 없이 브리프 133행 수정)
- [x] **D3. 브리프 동기화** (2026-11-25 완료): 오늘의 구현 결정 일곱 개(Next.js 16, 서버 쿠키 세션, JSON 내보내기, `service_role`로 접속 유지 상태 기록, Tailwind CSS 단독, 운영 프로젝트의 시험용 계정으로 e2e, iOS 유지)를 브리프 "Key Decisions"에 추가
- [x] **D3a. git 저장소** (2026-11-28 확인: `iwasthomas/scattered-notepad`, main 푸시됨): `scattered-notepad`(공개, 포트폴리오 겸 다른 PC 작업용). 시험 페이지(`scattered-notepad-spike/`)는 git에서 제외. 첫 커밋 전에 공개되는 문장 확인
- [ ] **D4. review (사용자가 직접 입력)**: `/egm:egm-review docs/designs/scattered-notepad.md` (스킬이 사용자 입력으로만 실행됨)
- [ ] **D5. resolve**: 리뷰 지적 사항을 항목별로 정리하고 반영할지 결정 (`/egm:egm-resolve`)
- [ ] **D6. 설계 승인**: 사용자가 승인한 뒤에만 구현 시작

## E. 슬라이스 0 구현 (D6 이후, 설계 문서의 "구현 순서")

앱 폴더는 `C:\mygit\pjy-dir\scattered-notepad\`(새로 만듦), DB 마이그레이션은 `supabase/migrations/`.

- [ ] **E0. 쿠키 세션 시험 앱 (게이트)**: 로그인과 쿠키 세션만 있는 최소 Next.js 앱을 Vercel에 배포하고 Android·iPhone에서 1일·3일·7일 뒤 로그인 유지를 기록. 실패하면 클라이언트 세션으로 바꿔 다시 시험. 이 시험이 끝나기 전에는 나머지 화면을 만들지 않음. (DB 마이그레이션 E1은 병행 가능)
- [ ] **E1. DB 마이그레이션 3개**: 핵심 스키마, RLS와 `GRANT`, 검색·완료 목록 함수. (`keepalive()` anon 권한 회수는 별도 파일로 나눠 시험 페이지 정리 뒤 적용)
- [ ] **E2. 화면·서버 액션·임시 저장**: 입력, 검색, 분류철, 완료 목록, 보관함, 설정
- [ ] **E3. 내보내기(JSON)와 접속 유지(cron, `service_role`)**, 서비스 워커
- [ ] **E4. 시험**: 단위(Vitest), e2e(Playwright, `rls.spec.ts` 먼저), 빌드 결과에서 `service_role` 키 검색
- [ ] **E5. 슬라이스 0 완료 조건**: 내보낸 JSON을 복원해 건수·해시 일치, 접속 유지 cron 자동 실행 기록 확인, iPhone·Android 세션 유지

### 사용자가 직접 할 일 (E 단계)
- [ ] **시험용 계정 만들기**: Supabase 대시보드 Authentication > Users에서 시험 전용 이메일 사용자 추가(가입 차단은 유지). 운영 계정과 이메일을 다르게 하고, 비밀번호는 `scattered-notepad\.env.test.local`에만 저장
- [ ] **Vercel 환경 변수 등록**: `SUPABASE_SERVICE_ROLE_KEY`(Sensitive), `CRON_SECRET`. 값은 채팅에 붙여 넣지 않음
- [ ] **실기기 기록**: E0의 1일·3일·7일 로그인 유지 결과를 알려 주기

## C. 판정 기준

| 시험 | 통과 조건 |
|---|---|
| B2 | "리포트클립"가 "리포트클립로"와 "리포트 클립"를 모두 찾고, 2글자 검색도 동작 |
| B3 | 가입 차단 후 외부 가입 요청이 실패 |
| B4 | 다른 사용자·비로그인은 메모를 읽거나 쓸 수 없음 |
| A4 | 7일 뒤에도 로그인 화면 없이 입력창이 열림(Android·iOS 각각) |
| B6 | cron 실행 기록과 DB 쿼리 로그가 모두 남음 |
