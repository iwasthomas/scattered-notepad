# 널브러진 메모장 (Scattered Notepad)

*   **Author:** iwasthomas
*   **Status:** Draft
*   **Date:** 2026-11-23

--------------------------------------------------------------------------------

## Overview

개인 한 명이 쓰는 웹 메모장입니다. PC 브라우저와 휴대폰 홈 화면(PWA)에서 같은 메모를 쓰고, 읽고, 검색합니다. 메모는 Supabase(Postgres)에 저장하고, 화면은 Vercel에 올립니다. 둘 다 무료 플랜만 씁니다. LLM과 유료 API는 쓰지 않습니다.

한 계정 안에 **회사 탭**과 **개인 탭**이 있습니다. 메모를 쓰면 질문 없이 바로 저장하고, 분류는 저장한 뒤에 합니다. 사용자는 분류철(예: 할일, 개발환경, 참조사항)을 직접 만들고, 분류하지 않은 메모는 미분류함에 남습니다. 메모마다 완료 시각을 비워 둘 수 있어서, 체크하면 시각이 남고 일간·주간·월간 완료 목록을 읽기 전용으로 볼 수 있습니다.

작성자는 기존 노트 도구(Keep, Joplin, Obsidian, Notion)를 먼저 써 보는 사전 시험을 하지 않기로 했습니다(2026-11-25 결정). 이 앱은 개발 연습을 겸해 직접 만들어 쓰는 것이고, 필요 없어지면 전체 내보내기로 다른 도구에 옮겨 관리할 계획입니다. 그래서 "기존 도구로 충분한가"는 이 설계의 폐기 조건이 아닙니다. 대신 내보내기가 실제로 동작하는 것이 필수 조건입니다.

**지금까지 시험으로 확인한 것 (2026-11-23)**

*   한국어 부분 일치 검색이 정규화 컬럼 + `ILIKE`로 동작합니다(메모 24건 시험).
*   가입 차단과 RLS가 동작합니다. 새 테이블에는 `GRANT`를 명시해야 합니다.
*   Android에서 홈 화면 설치, 로그인, 저장, 세션 유지를 확인했습니다. 며칠 뒤 유지 여부와 iOS는 아직 확인하지 못했습니다.
*   Supabase Free 플랜은 자동 백업이 없고, 7일간 활동이 적으면 프로젝트가 정지됩니다. 정지 후 1년 안에는 대시보드에서 복구할 수 있습니다.

## The Problem

메모가 세 곳에 흩어져 있습니다. 회사에서는 Notepad++ 파일, 집에서는 카카오톡 "나에게 보내기", 휴대폰에서는 삼성 Notes를 씁니다. 세 곳을 한꺼번에 검색할 수 없어서 "리포트클립 개발 방법이 어디 있더라?"를 찾지 못합니다. 회사 PC의 로컬 파일은 집이나 휴대폰에서 볼 수도 없습니다.

할 일을 끝내면 지워 버리기 때문에 이번 주에 무슨 일을 했는지 기록이 남지 않습니다. 주간보고를 쓸 때 기억에 의존합니다.

작성자는 9년 동안 메모를 정리하지 않았습니다. 병목은 정리 부족이 아니라 저장 위치가 흩어져 있고 검색이 안 되는 것입니다. 그래서 이 설계는 정리를 요구하지 않습니다. 저장과 검색, 완료 기록을 먼저 만들고, 분류는 사용자가 나중에 원할 때 하는 선택 기능으로 둡니다.

## Goals

성공 기준은 Notepad++을 열 일이 없어지는 것입니다. 슬라이스 0(저장 코어)을 쓰기 시작하고 한 달 뒤에 아래 두 가지를 확인합니다.

*   Notepad++, 카카오톡 나에게 보내기, 삼성 Notes 세 곳에 새로 적은 메모가 주 1건 이하입니다.
*   주간 완료 목록을 주간보고를 쓸 때 1회 이상 참고했습니다.

이를 위해 다음을 만듭니다.

*   **한 곳에 저장**: PC 웹과 휴대폰(Android, iPhone)의 홈 화면 앱에서 같은 메모를 읽고 씁니다. iPhone 홈 화면 앱에서 며칠 뒤에도 로그인 화면 없이 입력창이 열리는 것을 슬라이스 0의 필수 통과 조건으로 둡니다(2026-11-25 결정, 브리프의 "사용 기기: Android와 iOS 둘 다" 유지). iOS는 아직 시험하지 않았습니다(Open Questions).
*   **1탭 저장**: 저장 버튼 한 번으로 저장합니다. 서버에 저장이 확인되기 전에는 입력을 지우지 않고, 실패하면 다시 보냅니다.
*   **한국어 부분 일치 검색**: "리포트클립"가 "리포트클립로"와 "리포트 클립"를 모두 찾습니다. 소문자, NFC 정규화, 공백 제거를 거친 검색용 컬럼에 `ILIKE`를 씁니다. 회사·개인 탭을 합쳐서 검색하고 탭 필터를 제공합니다. 보관한 메모도 검색에 포함하고 표시로 구분합니다.
*   **완료 기록**: 메모마다 비워 둘 수 있는 완료 시각을 두고, 체크하면 시각이 찍힙니다. 체크박스는 "할일" 분류철에서만 보입니다. 일간·주간·월간 완료 목록은 읽기 전용이고 KST 기준, 주는 월요일에 시작합니다. 완료는 취소할 수 있고 시각을 고치는 화면은 없습니다.
*   **분류철**: 사용자가 만든 분류철과 미분류함이 있습니다. 회사 탭과 개인 탭은 분류철과 학습 이력을 따로 갖습니다. 저장한 뒤에 탭해서 분류철을 바꿉니다(폰·PC 동일). 미분류 개수와 방치 일수를 화면에 보여 줍니다.
*   **데이터 보호**: 이메일+비밀번호 로그인, 모든 테이블에 RLS, 가입 차단을 둡니다. 삭제 대신 보관하고, 영구 삭제는 보관함 안에서 확인 뒤에만 가능합니다.
*   **전체 내보내기 (필수)**: 이 앱은 필요 없어지면 다른 도구로 옮겨 관리하는 것을 전제로 만듭니다. 그래서 내보내기는 백업 수단이 아니라 탈출 경로입니다. 모든 메모를 앱 없이 읽을 수 있는 형식으로 내려받습니다. 슬라이스 0의 완료 조건에 "내보낸 파일을 다른 도구에서 열어 보거나 다시 가져와 내용이 같은지 확인하는 시험"을 포함합니다. 형식은 Technical Plan에서 정합니다.
*   **접속 유지**: 실제 DB 쿼리로 하는 접속 유지(Vercel cron 하루 1회)를 하고, 그 성공·실패를 화면에 표시합니다. 무료 플랜은 자동 백업이 없어서, 앱의 내보내기와 별도로 PC에서 `pg_dump`를 보조 수단으로 씁니다.
*   **가져오기**: 사용자가 고른 메모를 txt 하나로 합쳐 한 번에 가져옵니다. 앱 밖의 일회성 스크립트로 하고, dry-run, 되돌리기, 정규화 해시 중복 제거를 포함합니다. 2026-09 이후 날짜가 있는 메모만 살리고, 날짜가 없는 메모는 작성일을 비워 두며 가져온 과거 할일에 완료 시각을 만들어 넣지 않습니다.

구현 순서는 얇은 수직 슬라이스로 합니다. 슬라이스 0(저장 코어) → 1(가져오기) → 2(키워드 규칙 기반 분류 제안) → 3(새 분류철 제안, 애니메이션, 드래그 다듬기)입니다.

## Non-Goals

*   파일·사진 저장
*   LLM 기반 분류와 새 분류철 이름 자동 생성. 외부 LLM·무료 AI 서비스도 쓰지 않습니다.
*   카카오톡·삼성 Notes 자동 불러오기, 공유 시트(Web Share Target) 연동
*   포트폴리오 생성, agent 작업 분석, 주간보고 자동 작성·복사
*   여러 사용자, 동료와의 공유
*   완전한 오프라인 큐와 충돌 처리. 서버 저장 확인 전 입력 유지와 재전송까지만 합니다.
*   완료 시각 편집 화면
*   `project` 필드. 필요할 때 추가합니다.
*   Blender 등 별도 UI 제작 도구. 웹 UI는 CSS/JS로 구현합니다.
*   슬라이스 0에서는 분류 제안을 하지 않습니다. 키워드 규칙 제안은 슬라이스 2, 새 분류철 제안은 슬라이스 3 이후입니다.

## Open Questions

*   **세션 유지 기간**: Android 홈 화면 앱은 같은 날 다시 열었을 때 세션이 유지됐습니다. 1일·3일·7일 뒤에도 유지되는지 모릅니다. 유지 기간 값과 만료 시 동작을 정해야 합니다.
*   **iOS**: 시험하지 않았습니다. iOS는 홈 화면 앱과 Safari의 저장소가 분리될 수 있어서, 홈 화면에서 다시 로그인해야 할 가능성이 있습니다. iPhone 홈 화면 앱 지원은 MVP 대상이므로, 서버 쿠키 세션과 클라이언트 세션 둘 다 7일 안에 로그인 화면이 다시 뜬다면 슬라이스 0을 끝낼 수 없고, 이 앱의 iOS 전제를 다시 정해야 합니다.
*   **기존 도구 사전 시험 (생략, 2026-11-25 결정)**: 작성자가 시험하지 않고 직접 만들어 쓰기로 했습니다. 개발 연습이 목적이고, 필요 없어지면 내보내기로 다른 도구에 옮깁니다. 따라서 이 설계가 만드는 위험은 "기존 도구로 충분했을 가능성"을 받아들이는 것이고, 그 비용은 개발 시간입니다. 이 시험 때문에 Technical Plan 이후 섹션을 미루지 않습니다.
*   **수천 건 규모의 검색 속도**: 시험은 24건으로 했습니다. 2글자 검색은 인덱스를 쓰지 못해 전체 스캔이 되므로, 메모가 쌓였을 때 느려지는지 측정하지 못했습니다.
*   **접속 유지(cron)**: Vercel 함수가 Supabase의 RPC를 호출해 DB 시각을 받아 오는 것은 확인했습니다(2026-11-25). cron이 스스로 실행된 기록은 아직 없습니다(2026-11-26 03:00 UTC 이후 확인).
*   **내보내기와 복원**: `pg_dump`로 받은 덤프를 임시 스키마에 복원했을 때 29건의 내용이 원본과 일치했고 인덱스·RLS 정책도 복원됐습니다(2026-11-25). `supabase db dump`는 Docker가 필요해서 Docker가 없는 PC에서는 쓸 수 없습니다. 앱의 내보내기 기능이 어떤 형식(JSON, Markdown 등)으로 내보낼지는 정해지지 않았습니다. 다른 도구로 옮기는 것이 이 앱의 탈출 경로이므로, 형식은 슬라이스 0에서 정해야 합니다.
*   **Vercel Hobby 약관**: 비상업·개인 용도로 제한됩니다. 이 앱이 해당하는지는 작성자의 판단입니다. 메모에 어떤 내용을 저장할지도 사용자가 정하며, 이 앱은 저장 내용에 대한 정책 확인을 대신하지 않습니다.

## Technical Plan (Architecture)

### 결정 요약 (2026-11-25, 작성자 선택)

*   **화면**: Next.js(App Router)와 React. 작성자가 React와 Next.js를 공부 중이고 포트폴리오로도 쓸 계획입니다. 시험 페이지(정적 파일 + 바닐라 JS)에서 구성이 바뀝니다.
*   **로그인 세션**: 서버 쿠키 세션(`@supabase/ssr`). 시험 페이지는 `localStorage` 세션이었고, 쿠키 세션은 홈 화면 앱에서 시험한 적이 없습니다. 아래 "슬라이스 0의 첫 단계"에 시험 조건을 둡니다.
*   **내보내기**: JSON 한 파일. 다른 노트 도구로 옮기려면 변환 스크립트가 따로 필요합니다(Future Improvements).
*   **접속 유지 상태 표시**: cron이 `service_role` 키로 상태 테이블에 결과를 기록합니다. RLS를 우회하는 키가 하나 생기고, 서버 환경 변수 밖으로 나가지 않아야 합니다.
*   **스타일링**: Tailwind CSS 단독(2026-11-25 작성자 결정). 처음에 Tailwind를 골랐다가 shadcn/ui를 더하는 쪽으로 바꾼 뒤, 같은 날 다시 Tailwind 단독으로 되돌렸습니다. 대화상자와 선택창은 브라우저 기본 요소(`<dialog>`, `<select>`)로 만들고, 컴포넌트 라이브러리는 쓰지 않습니다. 슬라이스 3의 포스트잇 테마를 기본 모양을 덮어쓰지 않고 처음부터 만들 수 있습니다. 대신 탭, 대화상자, 선택창의 키보드·스크린 리더 동작을 직접 확인해야 합니다.
*   **시험 구성**: Vitest(단위)와 Playwright(브라우저 e2e)를 쓰고, e2e는 운영 Supabase 프로젝트의 시험용 계정으로 합니다. 이 PC에는 Docker가 없어서 로컬 Supabase를 쓸 수 없습니다. 운영 데이터를 지킬 규칙은 Verification Plan에 둡니다.

### 구성

```text
 휴대폰(홈 화면 앱) / PC 브라우저
            │  쿠키 세션
            ▼
 ┌──────────────────────────────────────────────┐
 │ Vercel: Next.js 프로젝트 하나                   │
 │  - 서버 컴포넌트: 로그인한 사용자로 DB를 읽음     │
 │  - 서버 액션: 메모 저장·체크·분류 변경           │
 │  - /api/export : 전체 내보내기(JSON)            │
 │  - /api/keepalive : cron 전용(하루 1회)         │
 └───────────────┬──────────────────────────────┘
                 │ anon 키 + 사용자 쿠키(RLS 적용)
                 │ service_role 키: /api/keepalive에서만
                 ▼
 ┌──────────────────────────────────────────────┐
 │ Supabase: Auth, Postgres(RLS), pg_trgm 인덱스   │
 └──────────────────────────────────────────────┘
```

서버 컴포넌트는 쿠키를 쓸 수 없으므로, 요청마다 쿠키의 토큰을 갱신하는 코드를 요청 가로채기 단계에 둡니다. Next.js 16에서는 이 파일이 `middleware.ts`가 아니라 `src/proxy.ts`(`export function proxy`)입니다(2026-11-25 공식 문서 확인). Next.js 15 이하에서는 `proxy.ts`가 호출되지 않아 세션이 갱신되지 않고 로그아웃되므로, Next.js 16 이상을 씁니다. 서버에서 로그인 여부를 판단할 때는 쿠키 값을 그대로 믿지 않고 `supabase.auth.getClaims()`로 토큰을 검증합니다. 토큰을 갱신한 응답에는 Supabase가 주는 `Cache-Control`, `Expires`, `Pragma` 헤더를 그대로 붙여서 CDN이 세션 쿠키를 캐시해 다른 사용자에게 주는 일이 없게 합니다.

### 데이터 모델

`system_status`를 뺀 모든 테이블에 `user_id`가 있고, 접근은 `user_id`가 로그인한 사용자와 같을 때만 허용합니다. `system_status`는 사용자별 데이터가 아니라 서비스 전체의 상태 한 줄이라서 `user_id`가 없고, 로그인한 사용자가 읽기만 합니다. 사용자는 한 명이지만 RLS는 그대로 둡니다. 가입 차단과 함께 이중 방어입니다.

| 테이블 | 열 | 설명 |
|---|---|---|
| `folders` | `id`, `user_id`, `space`('company'·'personal'), `name`, `is_todo`, `sort_order`, `archived_at`, `created_at` | 분류철. 탭마다 따로 갖습니다. `is_todo`가 참인 분류철만 체크박스를 보여 주고, 탭마다 하나만 허용합니다. |
| `memos` | `id`, `user_id`, `space`, `folder_id`(비어 있으면 미분류), `body`, `body_norm`(자동 계산), `written_at`(비울 수 있음), `written_at_source`('original'·'estimated'·'none'), `completed_at`(비울 수 있음), `archived_at`(비울 수 있음), `created_at`, `updated_at` | 메모. `written_at`은 가져온 메모의 원래 작성일이고, `created_at`은 이 앱에 저장된 시각입니다. |
| `classification_events` | `id`, `user_id`, `memo_id`, `from_folder_id`, `to_folder_id`, `created_at` | 분류철을 바꿀 때마다 한 줄 기록합니다. 슬라이스 0부터 쌓고, 분류 제안(슬라이스 2)의 근거가 됩니다. |
| `system_status` | `key`, `last_ok_at`, `last_error`, `updated_at` | 접속 유지 결과 한 줄(`key = 'keepalive'`). 로그인한 사용자는 읽기만 합니다. |

*   **권한**: 이 프로젝트는 새 테이블에 `anon`과 `authenticated`의 권한이 기본으로 없습니다(2026-11-23 시험). 모든 테이블마다 마이그레이션에 `authenticated`에게 필요한 권한(`SELECT`, `INSERT`, `UPDATE`, `DELETE`)을 명시하고, `anon`에게는 아무것도 주지 않습니다. `system_status`는 `authenticated`에게 `SELECT`만 줍니다.
*   **상태 모델**: 메모의 상태는 세 축입니다. 분류(`folder_id`가 비었는가) × 완료(`completed_at`이 비었는가) × 활성(`archived_at`이 비었는가). 상태 값을 따로 저장하지 않고 이 세 열에서 계산합니다.
*   **삭제**: 메모와 분류철은 `archived_at`만 채우고 지우지 않습니다. 영구 삭제는 보관함 화면에서 확인을 거친 뒤에만 `DELETE`를 실행합니다.
*   **시간**: 모든 시각은 `timestamptz`로 저장합니다. 일·주·월 경계는 `Asia/Seoul` 기준으로 계산하고, 주는 월요일에 시작합니다(PostgreSQL의 `date_trunc('week')`가 이미 월요일 시작입니다).

### 검색

검색 정규화 규칙은 한 곳에 둡니다. DB 함수 `norm_text(text)`(소문자, NFC 정규화, 모든 공백 제거)를 만들고, 두 곳이 이 함수만 씁니다.

1.  `memos.body_norm`은 `norm_text(body)`로 자동 계산되는 열입니다. 시험에서 같은 계산을 자동 계산 열로 만들어 통과했습니다(24건).
2.  검색 함수 `search_memos(q, space, include_archived)`가 검색어에 같은 `norm_text`를 적용하고, `%`·`_`·`\`를 이스케이프한 뒤 `body_norm ILIKE '%…%'`로 찾습니다.

앱은 검색할 때 이 함수만 호출하므로 정규화 규칙이 앱과 DB에 두 벌 생기지 않습니다. `body_norm`에는 `pg_trgm` GIN 인덱스를 둡니다. 검색어가 두 글자 이하이면 인덱스를 쓰지 못해 전체 스캔이 됩니다. 보관한 메모도 기본으로 검색에 포함하고 화면에서 표시로 구분하며, 필터로 뺄 수 있습니다.

### 저장 흐름과 임시 저장

1.  저장 버튼을 누르면 브라우저가 메모의 `id`(UUID)를 직접 만들고, 입력 내용을 브라우저 저장소(IndexedDB)의 "전송 대기" 목록에 먼저 씁니다.
2.  서버 액션이 같은 `id`로 `memos`에 넣습니다(이미 있으면 갱신).
3.  서버가 성공을 응답하면 전송 대기 목록에서 지웁니다. 실패하거나 응답이 없으면 남겨 두고 "전송 대기 N건"을 보여 줍니다. 앱을 열 때와 네트워크가 돌아올 때 다시 보냅니다.

`id`를 브라우저가 정하므로, 응답만 늦고 저장은 됐던 경우에 다시 보내도 같은 메모가 두 번 생기지 않습니다. 슬라이스 0의 임시 저장은 새 메모 생성만 다룹니다. 수정·체크·분류 변경은 온라인일 때만 하고, 완전한 오프라인 큐와 충돌 처리는 Non-Goal입니다.

### 완료 목록

*   체크하면 `completed_at = now()`, 취소하면 `completed_at = NULL`입니다. 시각을 고치는 화면은 없습니다.
*   일간·주간·월간 목록은 `completed_at`이 해당 기간(KST) 안에 있는 메모를 최신순으로 읽기만 합니다. `is_todo` 분류철이 아닌 메모도 `completed_at`이 있으면 목록에 포함됩니다.
*   가져온 과거 할일에는 `completed_at`을 넣지 않습니다.

### 접속 유지

Vercel cron이 하루 1회 `/api/keepalive`를 부릅니다. 이 경로는 Vercel이 보내는 `CRON_SECRET` 헤더가 맞을 때만 실행합니다. 실행하면 DB 함수 `keepalive()`로 실제 쿼리를 보내고, 성공이면 `system_status`의 `last_ok_at`을, 실패면 `last_error`를 `service_role` 키로 기록합니다. 화면 상단에는 마지막 성공 시각을 보여 주고, 경과 시간이 기준을 넘으면 경고합니다. 경고 기준은 초안 값으로 48시간으로 두고, Supabase Free 플랜이 7일간 활동이 적으면 프로젝트를 정지한다는 점(2026-11-23 공식 문서)을 근거로 슬라이스 0에서 확정합니다.

`service_role` 키는 서버 전용 환경 변수로만 두고, 이름 앞에 `NEXT_PUBLIC_`을 붙이지 않으며, `/api/keepalive` 외의 코드에서는 쓰지 않습니다. 사용자가 보는 화면의 코드와 번들에 들어가면 안 됩니다.

### 내보내기

로그인한 사용자가 `/api/export`를 열면, 사용자 쿠키(RLS 적용)로 읽은 모든 데이터를 JSON 한 파일로 내려받습니다. 내용은 `format_version`, `exported_at`, `folders`, `memos`, `classification_events`입니다. `body_norm`은 `body`에서 다시 계산되므로 넣지 않습니다. 메모가 수만 건 이하의 텍스트라는 가정으로 한 번에 응답하며, 이 가정이 깨지는 규모가 되면 나눠 받는 방식을 다시 정합니다. 내보낸 JSON을 새 계정(또는 빈 테이블)에 다시 넣는 복원 스크립트를 앱 밖에 만들고, 이것이 슬라이스 0의 내보내기 완료 시험입니다.

### 환경 변수와 비밀

| 이름 | 공개 여부 | 쓰는 곳 |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` | 공개용(화면 코드에 들어감) | 브라우저와 서버 |
| `SUPABASE_SERVICE_ROLE_KEY` | 비밀(Vercel의 Sensitive 변수) | `/api/keepalive`만 |
| `CRON_SECRET` | 비밀 | `/api/keepalive`의 호출자 확인 |

로컬 비밀은 `.env`에만 두고 `.gitignore`로 git에서 제외합니다(적용됨). DB 비밀번호는 앱이 쓰지 않습니다. `pg_dump` 같은 PC 작업에만 필요합니다.

### 슬라이스 0의 구성과 첫 단계

화면은 `/login`, `/`(입력창, 최근 메모, 회사·개인 탭 전환), `/search`, `/folders/[id]`, `/done`(일·주·월), `/archive`, `/settings`(내보내기, 접속 유지 상태)입니다.

**첫 단계는 쿠키 세션 시험입니다.** 로그인과 쿠키 세션만 있는 최소한의 Next.js 앱을 Vercel에 올리고, Android와 iPhone에서 홈 화면에 설치해 1일·3일·7일 뒤에 로그인 화면 없이 입력창이 열리는지 기록합니다. Android 또는 iPhone 중 한쪽이라도 7일 안에 로그인 화면이 다시 뜨면 이 결정(서버 쿠키 세션)을 취소하고 클라이언트 세션(`supabase-js` + `localStorage`)으로 바꿔 같은 시험을 다시 합니다. iPhone이 두 방식 모두 실패하면 슬라이스 0을 끝낼 수 없습니다(Open Questions의 iOS 항목). 이 시험이 끝나기 전에는 나머지 화면을 만들지 않습니다.

## Alternatives Considered

### 제품 방향에 대한 대안 (concepts brief, 2026-11-21~23)

#### Alternative A: Notepad++ 습관을 유지하고 백업 폴더만 읽어서 분류

*   **Pros**: 새로 만들 것이 없고, 지금 쓰는 도구를 바꾸지 않습니다.
*   **Cons**: 메모를 집과 휴대폰에서 볼 수 없습니다.
*   **Reason for Rejection**: Rejected by author: 집과 휴대폰에서 메모를 확인할 수 없어서 성공 기준을 채우지 못합니다.

#### Alternative B: 설치형 데스크톱 앱

*   **Pros**: 오프라인에서 동작하고 PC에서 빠릅니다.
*   **Cons**: 기기 사이에서 메모가 동기화되지 않습니다.
*   **Reason for Rejection**: Rejected by author: 기기 간 접근이 필요한데 설치형은 해결하지 못합니다. 웹 기반 동기화가 필수입니다.

#### Alternative C: 외부 LLM 또는 무료 AI 서비스로 자동 분류

*   **Pros**: 키워드 규칙보다 분류 정확도가 높을 수 있습니다.
*   **Cons**: 무료 요금제는 호출 한도와 입력 사용 약관 위험이 있습니다. 업무 메모를 외부로 보내야 합니다.
*   **Reason for Rejection**: Rejected by author: 업무와 관련된 내용을 외부 AI 서비스로 보내는 것은 하지 않기로 했습니다. 브라우저 안의 작은 임베딩 모델은 슬라이스 3 이후로 미룹니다.

#### Alternative D: Blender로 UI 제작

*   **Pros**: 포스트잇이 분류철로 들어가는 연출을 3D로 만들 수 있습니다.
*   **Cons**: Blender는 3D 제작 도구이고 웹·앱 화면을 만드는 도구가 아닙니다.
*   **Reason for Rejection**: Rejected after review: 웹에서 CSS/JS 애니메이션으로 만들고, 슬라이스 3에서 다듬습니다.

#### Alternative E: Supabase 대신 다른 무료 DB (Neon, Turso, Firebase)

*   **Pros**: Supabase 외 선택지가 있고, 일부는 한도가 다릅니다.
*   **Cons**: 로그인, 행 수준 보안, 검색을 따로 묶어야 합니다.
*   **Reason for Rejection**: Rejected: 로그인, RLS, 검색(`pg_trgm`)이 한곳에 묶인 Supabase가 이 용도에 가장 손이 덜 갑니다. DB 500MB 할당량은 텍스트 전용 메모에 충분합니다(2026-11-23 공식 문서).

#### Alternative F: 기존 노트 도구(Keep, Joplin, Obsidian + Tasks, Notion) 사용

*   **Pros**: 동기화, 검색, 체크리스트가 이미 있고 만들 필요가 없습니다.
*   **Cons**: 완료 시각 기반 주간 목록이 없고, 개발 연습이라는 목적을 채우지 못합니다.
*   **Reason for Rejection**: Rejected by author: 작성자가 사전 시험 없이 직접 만들어 쓰기로 했습니다(2026-11-25). 개발 연습이 목적이고, 필요 없어지면 JSON 내보내기로 다른 도구에 옮깁니다. 리뷰어의 "기존 도구로 충분할 수 있다"는 반론은 해소된 것이 아니라 작성자가 비용(개발 시간)을 알고 받아들인 것입니다.

#### Alternative G: "할일"을 분류철이 아니라 모든 메모에 붙는 속성으로 처리

*   **Pros**: 개발환경 메모에 적힌 "~확인해야함"도 주간 완료 목록에 들어갑니다. 리뷰어 전원이 권했습니다.
*   **Cons**: 사용자가 생각하는 "할일 분류철" 화면과 달라집니다.
*   **Reason for Rejection**: Rejected by author: "분류철 중 하나"로 결정했습니다. 절충안으로 `completed_at`을 분류철과 독립된 열로 두고, 화면에서만 "할일"을 분류철처럼 보여 줍니다(채택).

### 구현 방식에 대한 대안 (2026-11-25)

#### Alternative H: 정적 파일 + 바닐라 JS 프런트엔드 (시험 페이지의 구성)

*   **Pros**: 빌드가 없고, PWA와 세션 유지가 Android에서 확인된 구성입니다.
*   **Cons**: 화면이 늘면 상태 관리와 화면 구조를 직접 만들어야 합니다.
*   **Reason for Rejection**: Rejected by author: React와 Next.js를 공부 중이고 포트폴리오로 쓰려는 목적입니다.

#### Alternative I: Vite + 가벼운 프레임워크의 SPA

*   **Pros**: 컴포넌트 구조와 빌드 결과가 정적 파일입니다.
*   **Cons**: 서비스 워커가 옛 번들을 캐시해서 새 버전이 보이지 않을 수 있습니다. 이 구성의 PWA는 시험하지 않았습니다.
*   **Reason for Rejection**: Rejected by author: Next.js를 쓰기로 하면서 선택하지 않았습니다. 별도로 밝힌 기술적 이유는 없습니다.

#### Alternative J: 클라이언트 전용 세션 (`supabase-js` + `localStorage`)

*   **Pros**: 시험 페이지와 같은 방식이라 Android에서 세션 유지가 확인됐습니다. 홈 화면 앱이 저장된 세션을 바로 읽습니다.
*   **Cons**: Next.js의 서버 컴포넌트·서버 액션을 거의 쓰지 못합니다. 브라우저가 저장소를 지우면 로그인 화면이 뜹니다.
*   **Reason for Rejection**: Rejected by author: 서버 쿠키 세션을 선택했고 별도로 밝힌 기술적 이유는 없습니다. 쿠키 세션 시험이 실패하면 이 대안으로 돌아갑니다(Technical Plan의 첫 단계).

#### Alternative K: 내보내기를 Markdown ZIP 또는 JSON + Markdown 둘 다로 제공

*   **Pros**: Obsidian 등에서 폴더째 바로 읽을 수 있습니다.
*   **Cons**: 다시 가져오기(복원)를 따로 만들어야 합니다. 서버에서 만들면 서버리스 함수 실행 시간 한도에 걸릴 수 있습니다. 둘 다 제공하면 구현과 시험이 두 배이고 서로 어긋날 수 있습니다.
*   **Reason for Rejection**: Rejected by author: JSON 한 파일로 정했고 별도로 밝힌 기술적 이유는 없습니다. 그 대가로, 다른 도구로 옮기려면 변환 스크립트가 필요합니다.

#### Alternative L: 접속 유지 상태를 `anon` 호출 함수로 갱신하거나, DB에 쓰지 않고 Vercel 로그로만 확인

*   **Pros**: `anon` 호출 함수 방식은 비밀 키가 늘지 않습니다. 로그만 보는 방식은 쓰기 권한이 필요 없습니다.
*   **Cons**: `anon` 방식은 `anon` 키를 아는 사람이 성공으로 위장할 수 있고, 로그 방식은 화면에 cron 결과가 나오지 않습니다.
*   **Reason for Rejection**: Rejected by author: `service_role` 키를 서버 환경 변수에 두는 방식을 선택했습니다. 별도로 밝힌 기술적 이유는 없습니다. 그 대가로 RLS를 우회하는 비밀 키를 관리해야 합니다.

#### Alternative M: Tailwind CSS + shadcn/ui

*   **Pros**: 탭, 확인 대화상자, 입력 폼을 빨리 만들고 접근성 처리가 기본으로 따라옵니다.
*   **Cons**: 복사된 컴포넌트 코드를 직접 유지해야 하고 의존성이 늘어납니다. 슬라이스 3의 포스트잇 테마를 입히려면 기본 모양을 많이 덮어써야 하고, 충돌하면 새로 만드는 것보다 어려워질 수 있습니다.
*   **Reason for Rejection**: Rejected by author: 같은 날 Tailwind 단독 → Tailwind + shadcn/ui → Tailwind 단독으로 두 번 바꿨고, 별도로 밝힌 기술적 이유는 없습니다.

#### Alternative N: CSS Modules

*   **Pros**: 의존성이 없고 순수 CSS로 애니메이션과 테마(CSS 변수)를 다루기 쉽습니다.
*   **Cons**: 파일이 늘고 공통 색·간격 변수를 직접 관리해야 합니다.
*   **Reason for Rejection**: Rejected by author: Tailwind CSS를 선택했고 별도로 밝힌 기술적 이유는 없습니다.

#### Alternative O: 시험 전용 Supabase 프로젝트를 따로 만들어 e2e 실행

*   **Pros**: 운영 데이터와 완전히 분리되고, 정리 코드 오류가 운영 데이터에 닿지 않습니다.
*   **Cons**: 프로젝트가 둘이 되어 마이그레이션을 두 곳에 적용해야 하고, 두 스키마가 어긋나면 시험은 통과하는데 운영에서 실패합니다.
*   **Reason for Rejection**: Rejected by author: 운영 프로젝트의 시험용 계정으로 e2e를 하기로 했습니다. 별도로 밝힌 기술적 이유는 없습니다. 그 대가로 운영 데이터를 지킬 규칙이 필요합니다.

#### Alternative P: e2e 자동화 없이 SQL 시험 스크립트와 실기기 수동 확인

*   **Pros**: 도구가 가장 적고 트랜잭션 롤백이라 데이터가 남지 않습니다.
*   **Cons**: 임시 저장과 재전송 같은 화면 흐름이 자동으로 검증되지 않습니다.
*   **Reason for Rejection**: Rejected by author: Playwright e2e를 쓰기로 했습니다. 별도로 밝힌 기술적 이유는 없습니다.

--------------------------------

## Non-Functional Requirements

*   **보안과 개인정보**
    *   브라우저가 가진 키는 `anon` 키뿐입니다. 이 키는 공개되어도 되도록 모든 테이블에 RLS를 켜고, `anon`에게는 어떤 권한도 주지 않습니다.
    *   `SUPABASE_SERVICE_ROLE_KEY`는 `/api/keepalive`에서만 읽습니다. 이 키가 화면 번들에 들어가지 않도록 `NEXT_PUBLIC_` 접두사를 쓰지 않고, 빌드 결과에서 키 문자열을 검색하는 시험을 둡니다.
    *   메모를 외부 클라우드(Supabase, Vercel)에 저장하는 것은 사용자의 판단입니다. 이 앱은 저장 내용에 대한 정책 확인을 대신하지 않습니다.
    *   이 앱을 포트폴리오로 공개할 때는 실제 메모가 보이면 안 됩니다. 로그인 없이는 아무 데이터도 보이지 않고(가입 차단), 공개용 시연은 실제 데이터가 없는 별도 계정이나 화면 캡처로 합니다. 소스를 공개 저장소에 올릴 때는 `.env`, `.env.*`, `backup/`이 제외되어 있어야 합니다.
*   **성능**
    *   홈 화면 앱을 열면 로그인 화면 없이 입력창이 뜨는 것이 속도 목표의 핵심입니다. 입력창은 서버 데이터를 기다리지 않고 먼저 그립니다.
    *   검색어가 두 글자 이하이면 인덱스를 쓰지 못해 전체 스캔이 됩니다. 메모가 수천 건이 되었을 때의 속도는 측정하지 못했고, 슬라이스 0 사용 중에 측정합니다.
*   **롤아웃과 롤백**
    *   새 프로젝트로 시작하고 시험 페이지(`scattered-notepad-spike`)는 건드리지 않습니다. 쿠키 세션 시험이 실패하면 클라이언트 세션으로 되돌립니다.
    *   마이그레이션은 되돌리는 SQL을 따로 두지 않습니다. 개인 한 명의 프로젝트이므로, 잘못된 마이그레이션은 새 마이그레이션으로 고치고, 큰 변경 전에는 `pg_dump`로 덤프를 받습니다.

--------------------------------

### Future Improvements

*   **JSON을 다른 노트 도구 형식으로 바꾸는 변환 스크립트**: 내보내기를 JSON 한 파일로 정했기 때문에, 다른 도구로 옮기는 날 필요합니다. 폴더·파일(Markdown) 변환부터 시작합니다.
*   **분류 제안(슬라이스 2, 3)**: 키워드 규칙 제안, 이력 기반 제안, 새 분류철 제안. 슬라이스 0부터 쌓는 `classification_events`가 근거입니다.
*   **포스트잇 애니메이션과 일러스트 테마(슬라이스 3)**: 색과 간격이 `globals.css`의 CSS 변수와 `src/components/ui/`의 자체 컴포넌트에 모여 있어서, 이 파일들만 고쳐 테마를 바꿀 수 있습니다.
*   **서버에서 나눠 받는 내보내기**: 메모가 많아져 한 번에 응답하기 어려워질 때.

--------------------------------

## Detailed Implementation Plan

작업 폴더는 `C:\mygit\pjy-dir`입니다. 이미 있는 `supabase/`(CLI 연결 완료, 원격 프로젝트 `scattered-notepad`)는 그대로 쓰고, 앱은 새 폴더 `scattered-notepad/`에 만듭니다. 패키지 관리자는 npm이고, Node.js는 설치된 v24를 씁니다. 아래 버전은 2026-11-25에 `npm view`로 확인한 최신 값이며, 설치할 때 `^`로 고정합니다: `next` 16.4.6, `react`·`react-dom` 19.3.1, `@supabase/ssr` 0.12.7, `@supabase/supabase-js` 2.119.2, `tailwindcss` 4.3.5, `vitest` 5.1.2, `@playwright/test` 1.65.1, `idb-keyval` 6.3.0.

### 구현 순서

1.  **쿠키 세션 시험 (게이트)**: 파일 6번~12번 중 로그인에 필요한 최소 파일만으로 앱을 만들어 Vercel에 올립니다. Android와 iPhone에서 1일·3일·7일 뒤 로그인 유지를 기록합니다. 실패하면 중단하고 설계를 고칩니다. 이 시험 중에도 3번(DB 마이그레이션)은 병행할 수 있습니다.
2.  DB 마이그레이션(파일 1~3)을 원격에 적용하고, 시험용 계정을 대시보드에서 만듭니다.
3.  나머지 화면과 서버 액션, 임시 저장, 내보내기, 접속 유지, 서비스 워커를 만듭니다.
4.  시험(Verification Plan)을 통과시키고, 접속 유지 cron의 첫 실행과 복원 시험으로 슬라이스 0을 마칩니다.

### Target Files to Create/Modify

#### 데이터베이스 (`C:\mygit\pjy-dir\supabase\migrations\`)

##### 1. `20261126000100_core_schema.sql` (Create)

*   **Type / Scope**: SQL 마이그레이션. 이미 적용된 `20261125000000_spike_keepalive.sql`보다 뒤의 타임스탬프를 씁니다.
*   **Proposed Changes**:
    *   함수 `public.norm_text(text) returns text`: `immutable`, 소문자로 바꾸고 NFC 정규화한 뒤 모든 공백을 제거합니다. 검색 정규화 규칙의 유일한 정의입니다.
    *   함수 `public.set_updated_at()` 트리거 함수와, `memos`·`folders`의 `updated_at` 갱신 트리거.
    *   테이블 `folders`: `id uuid pk default gen_random_uuid()`, `user_id uuid not null references auth.users`, `space text not null check in ('company','personal')`, `name text not null check (btrim(name) <> '')`, `is_todo boolean not null default false`, `sort_order integer not null default 0`, `archived_at timestamptz`, `created_at`, `updated_at`. `unique (id, user_id, space)`(메모의 복합 외래 키 대상). `is_todo`는 `(user_id, space)`마다 하나만 참이 되도록 부분 고유 인덱스를 둡니다. 보관하지 않은 분류철의 이름은 `(user_id, space, lower(name))`로 고유합니다.
    *   테이블 `memos`: `id uuid pk`(기본값 없음, 클라이언트가 보냄), `user_id`, `space`, `folder_id uuid`, `body text not null check (btrim(body) <> '')`, `body_norm text generated always as (public.norm_text(body)) stored`, `written_at timestamptz`, `written_at_source text not null default 'none' check in ('original','estimated','none')`, `completed_at timestamptz`, `archived_at timestamptz`, `created_at timestamptz not null default now()`, `updated_at`. 복합 외래 키 `(folder_id, user_id, space) references folders (id, user_id, space)`: `folder_id`가 비면 검사하지 않으므로 미분류가 가능하고, 다른 탭이나 다른 사용자의 분류철에는 넣을 수 없습니다. `written_at`이 비어 있으면 `written_at_source`는 `'none'`이어야 합니다(check).
    *   테이블 `classification_events`: `id uuid pk default gen_random_uuid()`, `user_id`, `memo_id uuid not null references memos on delete cascade`, `from_folder_id uuid`, `to_folder_id uuid`, `created_at`.
    *   테이블 `system_status`: `key text pk`, `last_ok_at timestamptz`, `last_error text`, `updated_at timestamptz not null default now()`. `user_id`는 없습니다. `('keepalive', null, null, now())` 한 줄을 넣어 둡니다.
    *   인덱스: `memos_body_norm_trgm`(`body_norm`에 `gin_trgm_ops`, 확장 `pg_trgm`은 `extensions` 스키마에 설치된 것을 씁니다. 시험에서 같은 방식이 통과했습니다), `memos (user_id, space, folder_id, created_at desc)`, `memos (user_id, completed_at) where completed_at is not null`, `classification_events (user_id, memo_id)`.

##### 2. `20261126000200_rls_and_grants.sql` (Create)

*   **Type / Scope**: SQL 마이그레이션. 접근 제어.
*   **Proposed Changes**:
    *   네 테이블 모두 `enable row level security`.
    *   `folders`, `memos`, `classification_events`: `authenticated`에게 모든 명령에 대한 정책 하나씩. `using`과 `with check` 모두 `user_id = (select auth.uid())`.
    *   `system_status`: `authenticated`에게 `select` 정책만(`using (true)`). 쓰기 정책은 없습니다. `service_role`은 RLS를 우회합니다.
    *   `grant select, insert, update, delete`를 세 테이블에서 `authenticated`에게, `system_status`는 `select`만 줍니다. `anon`에게는 어떤 테이블에도 주지 않습니다(이 프로젝트는 새 테이블에 기본 권한이 없습니다).

##### 3. `20261126000300_search_and_done_functions.sql` (Create)

*   **Type / Scope**: SQL 마이그레이션. 검색과 완료 목록의 계산을 DB 한 곳에 둡니다. 두 함수 모두 `security invoker`(호출한 사용자의 RLS 적용)입니다.
*   **Proposed Changes**:
    *   `public.search_memos(p_query text, p_space text default null, p_include_archived boolean default true) returns setof public.memos`: `norm_text(p_query)`를 구하고, 비어 있으면 빈 결과를 돌려줍니다. 아니면 `\`, `%`, `_`를 이스케이프한 뒤 `body_norm ilike '%' || … || '%'`로 찾고, `p_space`·`p_include_archived`로 거르며, `created_at` 내림차순으로 최대 200건을 돌려줍니다.
    *   `public.completed_memos(p_period text, p_anchor date default ((now() at time zone 'Asia/Seoul')::date), p_space text default null) returns setof public.memos`: `p_period`는 `'day'`·`'week'`·`'month'`만 허용합니다. 시작은 `date_trunc(p_period, p_anchor::timestamp) at time zone 'Asia/Seoul'`(주는 월요일 시작), 끝은 시작에서 하루·한 주·한 달 뒤이고, `completed_at`이 [시작, 끝)에 있는 메모를 `completed_at` 내림차순으로 돌려줍니다.
    *   두 함수의 `execute` 권한은 `public`에서 거두고 `authenticated`에게만 줍니다.
    *   `keepalive()`는 `20261125000000_spike_keepalive.sql`에서 이미 만들었으므로 다시 만들지 않습니다. 단, 그 함수는 `anon`에게도 열려 있으므로, `anon`의 `execute`를 거두고 `service_role`에게만 주는 변경을 이 파일에 포함합니다(cron이 `service_role`로 호출). **적용 시점 주의**: 시험 페이지의 cron(`scattered-notepad-spike/api/keepalive.js`)이 `anon` 키로 이 함수를 부르고 있습니다. 이 변경을 적용하면 시험 페이지의 접속 유지가 실패하므로, 시험 페이지의 cron 첫 자동 실행 확인(2026-11-26 이후)이 끝나고 새 앱의 cron이 대신 돌기 시작한 뒤에 적용합니다. 그 전까지는 이 변경만 별도 마이그레이션 파일로 나눠 둡니다.

#### 앱 설정 (`C:\mygit\pjy-dir\scattered-notepad\`)

##### 4. `package.json`, `package-lock.json`, `tsconfig.json`, `next.config.ts`, `eslint.config.mjs`, `postcss.config.mjs` (Create)

*   **Type / Scope**: 프로젝트 설정. `npx create-next-app@latest`(TypeScript, App Router, `src/` 폴더, ESLint, Tailwind, Turbopack, 가져오기 별칭 `@/*`)로 만든 뒤, 필요 없는 예시 파일(기본 홈 화면, 기본 이미지)을 지웁니다.
*   **Proposed Changes**: `package.json`의 scripts는 `dev`, `build`, `start`, `lint`, `typecheck`(`tsc --noEmit`), `test`(`vitest run`), `test:e2e`(`playwright test`), `restore`(`tsx scripts/restore-from-export.ts`)를 둡니다. 의존성에 `@supabase/ssr`, `@supabase/supabase-js`, `idb-keyval`을, 개발 의존성에 `vitest`, `fake-indexeddb`, `@playwright/test`, `tsx`, `dotenv`를 추가합니다. `next.config.ts`에는 별도 설정을 두지 않습니다.

##### 5. `src/app/globals.css`, `src/components/ui/button.tsx`, `input.tsx`, `textarea.tsx`, `badge.tsx`, `dialog.tsx` (Create)

*   **Type / Scope**: Tailwind 기반 자체 기본 컴포넌트. 컴포넌트 라이브러리는 쓰지 않습니다.
*   **Proposed Changes**: `globals.css`에 Tailwind v4의 `@theme`로 색, 간격, 글자 크기를 CSS 변수로 모읍니다. `button`, `input`, `textarea`, `badge`는 변수만 쓰는 작은 컴포넌트입니다. `dialog`는 브라우저 기본 `<dialog>`와 `showModal()`을 감싼 것으로, 초점 가두기와 `Esc` 닫기를 브라우저가 처리합니다. 선택창(분류철 고르기, 기간 전환)은 기본 `<select>` 또는 버튼 목록을 `dialog`에 넣어 만들고, 탭 전환은 `aria-current`를 쓴 링크로 만듭니다. 알림 팝업은 만들지 않고 화면 안의 상태 문구로 보여 줍니다. 슬라이스 3에서 테마를 바꿀 때는 `globals.css`의 변수와 `ui/*`만 고칩니다.

##### 6. `src/proxy.ts` (Create)

*   **Type / Scope**: Next.js 16 요청 가로채기.
*   **Proposed Changes**: `export async function proxy(request)`가 `lib/supabase/proxy.ts`의 `updateSession`을 부릅니다. `matcher`는 `_next/static`, `_next/image`, 아이콘, `sw.js`, `manifest.webmanifest`, `api/keepalive`를 뺀 모든 경로입니다.

##### 7. `src/lib/supabase/proxy.ts`, `server.ts`, `client.ts`, `admin.ts` (Create)

*   **Type / Scope**: Supabase 클라이언트 4종.
*   **Proposed Changes**:
    *   `proxy.ts`: 요청 쿠키로 서버 클라이언트를 만들고 `auth.getClaims()`로 토큰을 갱신합니다. 갱신된 쿠키를 요청과 응답 양쪽에 쓰고, `setAll`이 넘겨주는 `Cache-Control`, `Expires`, `Pragma` 헤더를 응답에 붙입니다. 로그인하지 않았고 경로가 `/login`이 아니면 `/login`으로 보냅니다.
    *   `server.ts`: 서버 컴포넌트·서버 액션용 `createClient()`. `cookies()`를 읽고, 쓰기 실패(서버 컴포넌트)는 무시합니다.
    *   `client.ts`: 브라우저용 `createBrowserClient`. 입력창 쪽에서 쓰지 않고 로그아웃 같은 최소한에만 씁니다.
    *   `admin.ts`: `SUPABASE_SERVICE_ROLE_KEY`로 만드는 클라이언트. 파일 맨 위에 `import 'server-only'`를 두고 `app/api/keepalive/route.ts`에서만 가져옵니다.

##### 8. `src/lib/types.ts` (Create)

*   **Type / Scope**: 데이터 행 타입(손으로 작성).
*   **Proposed Changes**: `Space`, `Folder`, `Memo`, `ClassificationEvent`, `SystemStatus`와 내보내기 JSON의 `ExportFile` 타입을 정의합니다. 스키마가 작아서 `supabase gen types`를 쓰지 않습니다. 마이그레이션을 바꾸면 이 파일도 같은 커밋에서 바꿉니다.

##### 9. `src/lib/queries.ts` (Create)

*   **Type / Scope**: 서버에서 읽는 함수 모음.
*   **Proposed Changes**: `listFolders(space)`, `recentMemos(space, limit)`, `folderMemos(folderId)`, `unclassifiedMemos(space)`(개수와 가장 오래된 메모의 방치 일수 포함), `searchMemos(q, space, includeArchived)`(`search_memos` 호출), `completedMemos(period, anchor, space)`(`completed_memos` 호출), `archivedMemos(space)`, `getKeepaliveStatus()`. 모두 `server.ts`의 클라이언트를 씁니다.

##### 10. `src/lib/actions/auth.ts`, `memos.ts`, `folders.ts` (Create)

*   **Type / Scope**: 서버 액션(`'use server'`).
*   **Proposed Changes**:
    *   `auth.ts`: `signIn(email, password)`은 `signInWithPassword`, `signOut()`. 가입 함수는 만들지 않습니다.
    *   `memos.ts`: `saveMemo({id, space, body, folderId?})`는 `upsert`(`on conflict id`)이고 본문이 비어 있으면 거부합니다. `setCompleted(id, done)`은 `completed_at`을 `now()` 또는 `null`로. `moveMemo(id, folderId|null)`은 `folder_id`를 바꾸고 `classification_events`에 한 줄을 더합니다(두 쓰기는 `rpc` 하나로 묶지 않고 순서대로 하며, 이벤트 기록 실패는 메모 이동을 취소하지 않고 로그만 남깁니다). `setArchived(id, archived)`, `deleteMemoPermanently(id)`(보관된 메모만 허용).
    *   `folders.ts`: `createFolder(space, name, isTodo)`, `renameFolder`, `setFolderArchived`.
    *   모든 액션은 결과를 `{ ok: true } | { ok: false, error }`로 돌려주고, 던지지 않습니다.

##### 11. `src/lib/pending-queue.ts` (Create)

*   **Type / Scope**: 임시 저장(전송 대기) 목록.
*   **Proposed Changes**: `idb-keyval`로 IndexedDB의 `pending-memos` 키에 `{id, space, body, folderId, createdAt}[]`를 저장합니다. `enqueue(item)`(id는 `crypto.randomUUID()`), `list()`, `remove(id)`, `flush()`(목록을 오래된 순으로 `saveMemo`에 보내고 성공한 것만 지움, 동시에 두 번 돌지 않도록 모듈 안에서 잠금)을 제공합니다. 실패한 항목은 그대로 두고 다음 `flush`에서 다시 보냅니다.

##### 12. `src/app/layout.tsx`, `src/app/login/page.tsx` (Create/Modify)

*   **Type / Scope**: 루트 레이아웃과 로그인 화면.
*   **Proposed Changes**: 루트 레이아웃에 `<html lang="ko">`, `manifest` 링크, `theme-color`, `apple-touch-icon`, 서비스 워커 등록 컴포넌트를 둡니다. 로그인 화면은 이메일·비밀번호 입력과 `signIn` 액션뿐이며 가입 링크가 없습니다. 실패하면 이유를 한 줄로 보여 줍니다.

##### 13. `src/app/(app)/layout.tsx`, `src/components/space-tabs.tsx`, `status-banner.tsx` (Create)

*   **Type / Scope**: 로그인 후 공통 레이아웃.
*   **Proposed Changes**: 서버에서 `getClaims()`로 로그인을 확인하고 아니면 `/login`으로 보냅니다. 위쪽에 회사·개인 탭 전환(선택한 탭은 쿠키 `space`에 저장해 새로고침해도 유지), 아래쪽에 이동 메뉴(입력, 검색, 분류철, 완료, 보관, 설정)를 둡니다. `status-banner`는 `getKeepaliveStatus()`로 마지막 성공 시각을 보여 주고, 48시간을 넘기거나 `last_error`가 있으면 경고색으로 바꿉니다.

##### 14. `src/app/(app)/page.tsx`, `src/components/capture-form.tsx`, `pending-sync.tsx` (Create)

*   **Type / Scope**: 입력 화면(홈).
*   **Proposed Changes**: 입력창을 서버 데이터를 기다리지 않고 먼저 그리고, 최근 메모 목록은 아래에서 따로 불러옵니다. 저장 버튼은 `enqueue` → `saveMemo` → 성공 시 `remove` 순으로 하며, 성공하기 전에는 입력 내용을 지우지 않습니다. `pending-sync`는 화면이 열릴 때와 `online` 이벤트에서 `flush()`를 부르고, 대기 건수를 "전송 대기 N건"으로 보여 줍니다. 저장 직후 분류철을 고르는 선택창(`folder-picker`)을 보여 주되 건너뛸 수 있습니다.

##### 15. `src/components/memo-list.tsx`, `memo-item.tsx`, `folder-picker.tsx`, `confirm-delete-dialog.tsx` (Create)

*   **Type / Scope**: 메모 목록 화면 부품.
*   **Proposed Changes**: `memo-item`은 본문, 작성일(`written_at`이 없으면 저장일)과 날짜 출처 표시, 분류철 이름, 보관 표시를 보여 줍니다. 체크박스는 메모가 `is_todo` 분류철에 있을 때만 보이고, 체크 해제가 완료 취소입니다. 분류철 변경은 탭하면 `folder-picker`가 열립니다. `confirm-delete-dialog`는 보관함에서만 쓰며, 영구 삭제 전에 한 번 더 묻습니다.

##### 16. `src/app/(app)/search/page.tsx`, `folders/page.tsx`, `folders/[id]/page.tsx`, `done/page.tsx`, `archive/page.tsx`, `settings/page.tsx` (Create)

*   **Type / Scope**: 나머지 화면.
*   **Proposed Changes**: 검색은 입력할 때마다가 아니라 제출 시 `searchMemos`를 부르고, 탭 필터와 보관 포함 여부 필터를 둡니다. 분류철 화면은 분류철 목록(미분류함 포함, 미분류 개수와 방치 일수)과 만들기·이름 바꾸기·보관을 제공합니다. 완료 화면은 일·주·월 전환과 이전·다음 이동(`anchor`)으로 `completedMemos`를 읽기만 합니다. 설정 화면은 내보내기 링크(`/api/export`)와 접속 유지 상태, 로그아웃을 둡니다.

##### 17. `src/app/api/export/route.ts` (Create)

*   **Type / Scope**: 전체 내보내기 라우트 핸들러(`GET`).
*   **Proposed Changes**: `server.ts`의 클라이언트로 `folders`, `memos`(`body_norm` 제외), `classification_events`를 전부 읽습니다(1,000건씩 범위를 나눠 모두 가져옴). 로그인하지 않았으면 401입니다. 응답은 `{format_version: 1, exported_at, folders, memos, classification_events}`를 `Content-Disposition: attachment; filename="scattered-notepad-YYYYMMDD.json"`으로 돌려주고 `Cache-Control: private, no-store`를 붙입니다.

##### 18. `src/app/api/keepalive/route.ts` (Create)

*   **Type / Scope**: cron 전용 라우트 핸들러(`GET`).
*   **Proposed Changes**: `Authorization: Bearer ${CRON_SECRET}` 헤더가 다르면 401입니다. 맞으면 `admin.ts`의 클라이언트로 `rpc('keepalive')`를 부르고, 성공이면 `system_status`의 `keepalive` 행에 `last_ok_at = now()`, `last_error = null`을, 실패면 `last_error`에 메시지를 기록합니다. 결과를 JSON으로 돌려주고 `console.log`로 Vercel 로그에도 남깁니다.

##### 19. `vercel.json` (Create)

*   **Type / Scope**: Vercel 설정.
*   **Proposed Changes**: `{"crons": [{"path": "/api/keepalive", "schedule": "0 3 * * *"}]}`. Vercel은 `CRON_SECRET` 환경 변수가 있으면 cron 호출에 `Authorization: Bearer` 헤더를 붙입니다.

##### 20. `public/manifest.webmanifest`, `public/icon-192.png`, `public/icon-512.png`, `public/apple-touch-icon.png`, `public/offline.html` (Create)

*   **Type / Scope**: PWA 자원.
*   **Proposed Changes**: 시험 페이지(`scattered-notepad-spike`)의 매니페스트와 아이콘 세 개를 복사하고, `start_url`은 `/`, `display`는 `standalone`로 둡니다. `offline.html`은 "오프라인입니다. 전송 대기 중인 메모는 이 기기에 남아 있습니다"만 보여 주는 정적 페이지입니다.

##### 21. `public/sw.js`, `src/components/sw-register.tsx` (Create)

*   **Type / Scope**: 서비스 워커.
*   **Proposed Changes**: 캐시 대상은 `/_next/static/`(파일 이름에 해시가 있어 바뀌지 않음), 아이콘, `offline.html`뿐입니다. 페이지 이동은 항상 네트워크를 먼저 시도하고 실패하면 `offline.html`을 보여 줍니다. `/api/*`, Supabase 주소, 로그인한 사용자의 HTML은 캐시하지 않습니다. 그래서 새 배포가 홈 화면 앱에 바로 보이고, 사용자 데이터가 캐시에 남지 않습니다. `sw-register`는 운영 빌드에서만 등록합니다.

##### 22. `.env.example`, `.gitignore`, `README.md` (Create)

*   **Type / Scope**: 환경 변수 목록과 사용법.
*   **Proposed Changes**: `.env.example`에는 이름만 적습니다(`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `CRON_SECRET`, `E2E_USER_EMAIL`, `E2E_USER_PASSWORD`). 실제 값은 `.env.local`과 `.env.test.local`에만 두고 둘 다 `.gitignore`에 넣습니다. `README.md`에는 실행·시험·배포 명령, `pg_dump`가 풀러 주소로 접속한다는 점(직접 주소는 IPv6 전용, Docker 없이는 `supabase db dump` 불가), `.env`의 `PGPASSWORD` 위치를 적습니다.

#### 앱 밖 스크립트와 시험 (`C:\mygit\pjy-dir\scattered-notepad\`)

##### 23. `scripts/restore-from-export.ts` (Create)

*   **Type / Scope**: 내보낸 JSON을 다시 넣는 복원 스크립트(앱 밖).
*   **Proposed Changes**: `E2E_USER_EMAIL`/`E2E_USER_PASSWORD`로 `anon` 키 클라이언트를 로그인시킨 뒤 JSON 파일을 읽어 `folders` → `memos` → `classification_events` 순으로 넣습니다. `user_id`는 로그인한 사용자의 값으로 바꾸고, 같은 `id`가 이미 있으면 건너뜁니다. `service_role` 키는 쓰지 않습니다. 끝나면 건수와 본문 해시를 JSON과 DB에서 각각 계산해 비교하고 결과를 출력합니다.

##### 24. `vitest.config.ts`, `tests/unit/pending-queue.test.ts`, `tests/unit/format.test.ts` (Create)

*   **Type / Scope**: 단위 시험.
*   **Proposed Changes**: `fake-indexeddb`로 `pending-queue`를 시험합니다: 저장 실패 시 항목이 남는지, 성공하면 지워지는지, 같은 `id`를 두 번 보내도 한 번만 처리하는지, `flush`가 동시에 두 번 불려도 중복 전송이 없는지. `format`은 KST 날짜 표시와 날짜 출처 표시를 시험합니다.

##### 25. `playwright.config.ts`, `tests/e2e/*.spec.ts`, `tests/e2e/helpers/*.ts` (Create)

*   **Type / Scope**: 브라우저 e2e 시험. 운영 Supabase 프로젝트와 시험용 계정을 씁니다(Verification Plan의 데이터 보호 규칙을 따릅니다).
*   **Proposed Changes**: 파일은 `rls.spec.ts`(항상 가장 먼저 실행), `auth.spec.ts`, `capture.spec.ts`, `search.spec.ts`, `done.spec.ts`, `export.spec.ts`와 `helpers/login.ts`, `helpers/cleanup.ts`입니다. `playwright.config.ts`는 `npm run build && npm run start`로 띄운 로컬 서버(`http://localhost:3000`)를 대상으로 하고, 크로미움 한 종류와 모바일 화면 크기 한 종류로 돌립니다.

#### 문서 수정

##### 26. `C:\mygit\pjy-dir\tasklist.md` (Modify)

*   **Type / Scope**: 작업 목록.
*   **Proposed Changes**: 사전 시험 목록 아래에 "슬라이스 0 구현" 목록을 추가합니다(위 구현 순서 1~4, 쿠키 세션 시험 게이트 포함). B8 정리 대상에서 `public.keepalive()`를 빼고 "슬라이스 0에서 계속 사용"으로 바꿉니다. 시험 계정 생성과 비밀 변수 등록을 사용자 작업(A 목록)으로 추가합니다.

##### 27. `C:\mygit\pjy-dir\concepts_brief.md` (Modify)

*   **Type / Scope**: 브리프.
*   **Proposed Changes**: 오늘 결정 여섯 개(Next.js, 쿠키 세션, JSON 내보내기, `service_role` 상태 기록, Tailwind CSS 단독, 운영 계정 e2e)를 "Key Decisions"에 한 줄씩 추가해 draft와 어긋나지 않게 합니다.

### Verification Plan

*   **Compilation/Build**: `cd scattered-notepad && npm run build`가 오류 없이 끝납니다. 빌드 결과(`.next/static`)에서 `SUPABASE_SERVICE_ROLE_KEY` 값과 `service_role`로 시작하는 JWT 문자열을 검색해 한 건도 나오지 않아야 합니다.
*   **Unit Tests**: `npm test`. 파일 24의 케이스가 모두 통과합니다.
*   **Static Analysis & Linting**: `npm run lint`와 `npm run typecheck`에 오류가 없습니다.
*   **Test Coverage Requirement**: 수치 목표는 두지 않습니다. 다음 항목은 반드시 시험합니다: ① 로그인 없이 `anon` 클라이언트가 세 테이블을 읽고 쓰면 `permission denied`, ② 시험 계정이 `memos`를 필터 없이 조회하면 모든 행의 `user_id`가 시험 계정, ③ 시험 계정이 다른 `user_id`로 쓰기를 시도하면 거부, ④ 검색에서 "리포트클립"가 "리포트클립로"·"리포트 클립"·NFD로 입력된 메모를 모두 찾고 두 글자 검색이 동작, ⑤ 저장 실패(네트워크 차단) 뒤 "전송 대기 N건"이 보이고 네트워크 복구 후 한 번만 저장, ⑥ 체크하면 주간 완료 목록(월요일 시작, KST)에 나오고 취소하면 사라짐, ⑦ `/api/export`가 로그인 없이 401이고 로그인하면 JSON이 내려옴, ⑧ 서버 액션 `deleteMemoPermanently`가 보관하지 않은 메모에 대해 거부.
*   **E2E/Integration**: `npm run test:e2e`. 운영 데이터를 지키기 위해 다음 규칙을 지킵니다.
    *   시험용 계정은 별도 이메일로 대시보드에서 직접 만들고(가입 차단 유지), 운영 계정의 이메일·비밀번호는 `.env.test.local`에 넣지 않습니다.
    *   e2e는 시험 계정으로 로그인한 `anon` 키 클라이언트만 씁니다. 시험 환경에 `SUPABASE_SERVICE_ROLE_KEY`를 두지 않습니다.
    *   시험이 만드는 메모와 분류철의 이름·본문은 모두 `[e2e]`로 시작하고, 정리 코드는 시험 계정으로 로그인한 상태에서 `[e2e]`로 시작하는 행만 지웁니다. RLS 때문에 운영 계정의 행은 정리 코드가 접근할 수 없습니다.
    *   `rls.spec.ts`가 실패하면 나머지 e2e를 실행하지 않고 중단합니다. RLS가 깨진 상태에서는 위 보호가 성립하지 않기 때문입니다.
*   **실기기 확인(자동화하지 않음)**: 쿠키 세션 시험 앱을 Android와 iPhone의 홈 화면에 설치하고 1일·3일·7일 뒤에 로그인 화면 없이 입력창이 열리는지 기록합니다. 슬라이스 0 완성 뒤에는 접속 유지 cron이 스스로 실행된 기록(Vercel 로그와 `system_status.last_ok_at`)을 확인합니다.
*   **내보내기 완료 시험**: `npm run restore -- <내보낸 파일>`을 시험 계정에서 실행해 건수와 본문 해시가 모두 일치하는지 확인합니다.

--------------------------------

<!-- Provenance: Indicates initial structural drafting via EGM. -->

*Drafted with EGM*
