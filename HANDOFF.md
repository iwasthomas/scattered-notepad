# 인계 문서 (Handoff)

*   **작성일**: 2026-11-29
*   **기준 커밋**: `main` (`ea79037` 이후). 작업 브랜치는 모두 `main`에 합치고 지웠습니다.
*   **목적**: 다른 기기(개인 PC, 노트북, 모바일)나 새 Claude 세션에서 이 작업을 바로 이어갈 수 있게 합니다.

## 1. 한 줄 요약

설계 문서 `docs/designs/scattered-notepad.md`를 egm 리뷰(Interactive 모드)로 다듬는 중입니다. 지금은 **Stage 8을 멈춘 상태**이고, 결정 하나만 남아 있습니다. 구현(슬라이스 0)은 설계 승인(D6) 뒤에 시작합니다.

## 2. 바로 다음에 할 일

1.  **새 cron을 확인할 방법을 정합니다.** 자세한 내용은 `intermediate_zoom_out_resolution_proposal.md`의 6번에 있습니다.
    *   **N2(추천)**: 시험 페이지 cron은 B8 정리 때까지 그대로 둡니다. 새 앱 cron은 실행 시각을 다르게 잡고(예: `30 15 * * *`, 한국 시간 00:30), 배포한 다음 날 Supabase API 로그로 한 번 확인합니다. 로그는 24시간만 남으므로 그 안에 봐야 합니다.
    *   **C5(지금 문서에 적힌 방식)**: 시험 페이지 cron을 끄고 `system_status.last_ok_at`으로 확인합니다.
2.  같은 제안서의 1~5번을 설계 문서에 반영합니다.
    *   M1: iPhone 게이트를 둘로 나눕니다. 구현 시작은 Android 7일 결과, 슬라이스 0 완료는 iPhone 결과를 기준으로 합니다.
    *   M2: 내보내기는 일반 JSON으로 응답합니다. 완료 시험은 "SQL로 센 건수 = 만들어진 파일 수"를 확인하고 Obsidian으로 열어 보는 것입니다.
    *   N3: 콜드 스타트 시간은 기록만 합니다.
    *   N4: Verification ⑦과 ⑫를 합칩니다.
    *   N5: 날짜 출처 표시는 슬라이스 1로 미루고, `format.ts`를 Target Files에 추가합니다.
    *   N1(분류철 보관 빼기)은 반영하지 않기로 했습니다.
    *   `tasklist.md`의 E0, E6도 함께 맞춥니다.
3.  **Stage 8 재검토**를 실행합니다. 재검토는 1회 남아 있습니다.
4.  **Stage 9 Implementation Readiness**를 실행합니다. 리뷰어는 `egm-implementation-readiness`, `egm-codebase-details`, `egm-style`이고, 대상은 DetailedRange(`## Detailed Implementation Plan`부터 끝까지)입니다. 결과는 `implementation_readiness_report.md`에 씁니다.
5.  D5(resolve)를 마치고, 사용자가 D6(설계 승인)를 하면 구현 E0부터 시작합니다.

### 새 세션에서 리뷰를 이어가는 방법

`/egm:egm-review docs/designs/scattered-notepad.md`를 다시 입력하면 처음부터 시작합니다. 아래 내용을 함께 알려 주면 이어서 진행할 수 있습니다.
*   모드: Interactive
*   현재 위치: Stage 8, 재검토 1회 남음. Stage 5·6은 재검토를 다 썼거나 끝났고, Stage 7은 1라운드 반영을 마쳤습니다.
*   GoldfishContext: `concepts_brief.md`, `tasklist.md`, `supabase/migrations/20261125000000_spike_keepalive.sql`, `supabase/config.toml`. Stage 6에는 주지 않습니다.
*   보고서는 작업 폴더 루트에 씁니다.

## 3. 사용자가 직접 할 일

*   [ ] **A4 Android 7일째 기록**(약 2026-11-30): 시험 페이지 홈 화면 앱이 로그인 없이 열리는지 기록합니다.
*   [ ] **iPhone 시험**: 시기는 정하지 않았습니다(2026-11-29 결정: 나중에). 이 시험이 끝나야 슬라이스 0을 마칠 수 있습니다.
*   [ ] **B8 정리**(A4가 끝난 뒤): 아래를 삭제하기 전에 다시 확인합니다.
    *   시험 테이블 `public.spike_memos`
    *   시험 페이지
    *   `backup/`
    *   DB 비밀번호 재설정
    *   `keepalive()`는 지우지 않고, `anon` 권한도 회수하지 않습니다.

## 4. 이번 리뷰에서 정한 주요 결정 (2026-11-29)

| 주제 | 결정 | 근거 위치 |
|---|---|---|
| 접속 유지 기록 | `service_role` 키를 쓰지 않습니다. `keepalive()`(`security definer`)가 `system_status.last_ok_at`을 직접 기록하고, cron은 `anon` 키로 부릅니다. | 설계 "접속 유지", Alternative L1~L3 |
| 저장 | 생성 전용(`on conflict (id) do nothing`)입니다. 서버로 보내는 곳은 `flush()` 하나뿐이고, 전송 대기 목록은 항목마다 IndexedDB 키를 둡니다. 저장한 뒤 선택창을 띄우지 않습니다. | 설계 "저장 흐름", 파일 10·11·14 |
| 분류 이력 | `memos`의 `after update of folder_id` 트리거가 같은 트랜잭션 안에서 기록합니다. | 설계 데이터 모델, 파일 1 |
| 분류철 | 보관해도 안의 메모는 그대로 둡니다. 할일 분류철은 보관할 수 없고, 영구 삭제는 빈 분류철만 됩니다. | 설계 "분류철 보관과 삭제" |
| 내보내기 | JSON 내보내기는 다른 도구로 옮기는 탈출 경로로, JSON → Markdown 변환 스크립트로 시험합니다. 백업과 복원은 `pg_dump`가 맡습니다. | 설계 "내보내기", Risks R1·R7 |
| 세션 게이트 | Android는 최대 7일, iPhone은 최대 14일입니다. Stage 8 M1을 반영하면 구현 시작과 슬라이스 0 완료 조건으로 나뉩니다. | 설계 "슬라이스 0의 첫 단계" |
| 운영 규칙 | `pg_dump`를 주 1회 받고, 성공 기준은 매주 금요일에 기록합니다. | `tasklist.md` 운영 규칙 |

## 5. 파일 지도

| 파일 | 내용 |
|---|---|
| `docs/designs/scattered-notepad.md` | 설계 문서(리뷰 대상) |
| `concepts_brief.md` | 입력 브리프와 결정 이력 |
| `tasklist.md` | 할 일 전체. A·B 사전 시험, D 리뷰, E 구현, 운영 규칙, 설계를 다시 고칠 계기 |
| `zoom_out_report.md`, `zoom_out_resolution_proposal.md` | Stage 5 보고서와 재검토, 처리 제안 |
| `comprehension_report.md` | Stage 6 보고서 |
| `critic_report.md`, `goldfish_review_report.md` | Stage 7 보고서와 처리(resolved) |
| `intermediate_zoom_out_report.md`, `intermediate_zoom_out_resolution_proposal.md` | Stage 8 보고서와 처리 제안(**미반영**) |
| `supabase/` | CLI 연결됨(원격 프로젝트 `scattered-notepad`, Seoul) |

git에 없는 파일(PC에만 있음):
*   `.env`: `PGPASSWORD`
*   `backup/`: `pg_dump` 덤프
*   `scattered-notepad-spike/`: 시험 페이지 소스

## 6. 알아 둘 점

*   **로그 보관 기간**: Vercel Hobby의 런타임 로그는 약 1시간만 남습니다. 대시보드에서도 3일 범위로 늘릴 수 없습니다. Supabase 무료 플랜의 로그는 24시간 남습니다. cron 실행 여부는 Supabase 대시보드 → Logs → API Gateway에서 `keepalive`로 검색해 확인합니다.
*   **Vercel CLI 로그**: `npx vercel logs --deployment <url>`은 프로젝트 폴더에서 실행해야 합니다. 긴 기간(`--since 3d`)은 비어 나올 수 있습니다.
*   **Vercel 응답 한도**: 함수 응답 본문은 4.5MB까지입니다. 스트리밍 응답에는 이 한도가 적용되지 않습니다(vercel.com/docs/functions/limitations).
*   **Windows PowerShell 5.1**:
    *   여러 줄 커밋 메시지는 `git commit -m @'...'@`로 넘깁니다. `-F -`에 here-string을 넘기면 실패합니다.
    *   `&&`는 쓸 수 없습니다.
*   **공개 저장소**: 커밋 전에 `.env*`, `backup/`, 키 문자열이 들어가지 않았는지 확인합니다.
*   **여러 기기 작업**: `main`이 기준입니다. 작업을 시작할 때 `git pull`하고, 끝낼 때 커밋하고 푸시합니다.
