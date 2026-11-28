# Goldfish Annotated Review Report

**Status: resolved** (2026-11-29, 사용자 "반영" 승인). PROPOSE FIX 25건 전부와 C4를 반영했습니다. C4는 "iPhone 시험은 나중에" 결정에 따라 "Android 최대 7일, iPhone 최대 14일"로 고쳤습니다. 아래 두 가지는 제안과 다르게 반영했습니다.
*   C8은 공식 문서 확인(스트리밍 응답에는 4.5MB 한도가 적용되지 않음)에 따라 "3MB 경고와 나눠 받기" 대신 스트리밍 응답과 `counts` 대조로 반영했습니다.
*   구현 계획의 같은 내용도 함께 맞췄습니다: 파일 1, 6, 7, 9, 10, 11, 13, 14, 16, 17, 23, 24, 26과 Verification Plan.

**Target:** `docs/designs/scattered-notepad.md` (FeatureRange 1-305, Stage 7 1라운드. 아래 X1~X4는 사용자 요청에 따라 함께 다루는 Stage 5·6의 열린 지적이며, 일부는 DetailedRange에 걸칩니다)

**근거 보고서:** `critic_report.md` (통합 조치 C1~C23), `zoom_out_report.md` 재검토 절, `comprehension_report.md`

**분류 요약:** PROPOSE FIX 25건(C1~C3, C5~C17 중 C4·C18 제외, C19~C23, X1~X4. C16은 일부만), ESCALATE 1건(C4), DECLINE 2건(C18, C16의 링크 부분)과 범위 밖 Stage 5 Nit 묶음, CONTEST 0건

**판단 원칙:**
*   리뷰어 주장 가운데 사실관계가 의심되는 것은 원문으로 다시 확인했습니다.
    *   예: C7의 "`on delete set null`이면 삭제 실패"는 PostgreSQL 15 이상의 열 지정 문법 `on delete set null (folder_id)`로 피할 수 있습니다. 다만 아래에서는 더 단순한 규칙을 제안합니다.
*   작성자의 동기를 제가 지어내지 않습니다.
    *   기각 사유(C1)는 문서와 브리프에 이미 적힌 이유(학습 목적, 각 대안의 Cons)만 옮깁니다.

---

## Prioritized Findings & AI Suggestions

### [ESCALATE 먼저] 

### [Issue C4] [`design` `structural` `style`] - Severity: Major
*   **Affected Scope:** Lines 172-174, 226, 238, 240 (슬라이스 0의 첫 단계, Alternative H·J)
*   **Discrepancy Description:** "게이트 최대 7일", "클라이언트 세션 시험을 다시 하지 않음"은 iPhone의 클라이언트 세션 7일 기록(A4)이 있어야 성립하는데, 문서는 iOS를 시험하지 않았다고 적습니다. Android의 "세션 유지 확인됐다"(226, 238행)도 실제로는 같은 날과 약 2일뿐입니다.
*   **Rationale:** iPhone이 필수 통과 조건(41행)이라 게이트가 14일로 늘 수 있습니다. 1·3·7일 시험 절차(중간에 앱을 여는지)도 정의되지 않았습니다.
*   ***AI Suggestion:*** ESCALATE (고칠 문장은 정해져 있으나 사실 하나가 필요함)
*   ***Justification:*** 지적은 맞습니다. 다만 고칠 문장은 "지금 iPhone에서 시험 페이지(A4)를 기록하고 있는가"에 달려 있고, 이 사실은 사용자만 압니다.
*   ***Proposed Edit:***
    *   Location: 174행, 226행, 238행, 240행
    *   Change (iPhone A4를 기록 중이거나 오늘 시작하는 경우): 174행 끝을 "Android와 iPhone 모두 A4로 클라이언트 세션을 기록하므로(iPhone 시작일 YYYY-MM-DD) 이 게이트는 최대 7일입니다"로 고칩니다.
    *   Change (iPhone A4가 없는 경우): "Android는 A4로 대체하므로 최대 7일, iPhone은 클라이언트 세션 기록이 없어 쿠키 세션이 실패하면 7일을 더 시험하므로 최대 14일"로 고칩니다.
    *   공통: 172행에 시험 절차 한 줄을 넣습니다. "홈 화면 앱을 설치한 날 로그인하고, 그 뒤 1일·3일·7일째에만 엽니다(중간에 열지 않음)."
    *   공통: 226, 238행의 "확인됐습니다"를 "같은 날 재실행에서 유지 확인, 7일 유지는 A4 진행 중"으로 고칩니다.

### [Issue C1] [`design` `structural` `style`] - Severity: Blocker
*   **Affected Scope:** Lines 234, 240, 246, 258, 264, 270, 276 (Alternative I, J, K, M, N, O, P)
*   **Discrepancy Description:** 기각 사유가 "별도로 밝힌 기술적 이유는 없습니다"뿐이라 표준의 Alternatives Rule("구체적인 기술 또는 범위 트레이드오프")을 어깁니다. K는 이유가 없다고 한 직후에 이유를 듭니다.
*   **Rationale:** 특히 J(클라이언트 세션)는 시험으로 확인된 구성입니다. 그런데도 시험하지 않은 쿠키 세션을 고른 이점과 비용을 비교하지 않았습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 문서에 이미 있는 근거로 채울 수 있습니다. 근거는 80행의 "React·Next.js 학습과 포트폴리오"와 각 항목의 Cons입니다. 새 동기는 만들지 않습니다. 각 사유 칸은 "범위 결정 / 기술 트레이드오프 / 받아들인 비용" 순서로 씁니다.
*   ***Proposed Edit:***
    *   I: "범위 결정: 학습 대상이 Next.js(80행)이므로 고르지 않았습니다. 기술 면에서 둘의 차이는 서버 렌더링 유무이며, I의 Cons인 '옛 번들 캐시'는 HTML을 캐시하지 않는 이 설계의 서비스 워커(파일 21)에서는 해당하지 않습니다."
    *   J: "범위 결정: 서버 컴포넌트·서버 액션을 쓰는 것이 학습 목표(80행)이고, J로는 이를 거의 쓰지 못합니다. 쿠키 세션의 이점은 서버에서 `getClaims()`로 로그인을 확인한다는 점입니다. 받아들인 비용은 세 가지입니다: 홈 화면 앱에서 시험하지 않은 방식이라 7일 게이트가 필요하고, 첫 화면이 서버 왕복을 기다리며(Risks R4), 오프라인 첫 실행에서 입력창이 없습니다(Risks R5). 쿠키 세션이 실패하면 이 대안으로 돌아갑니다."
    *   K: "이유 없음" 문장을 지우고 "기술 트레이드오프: 서버에서 Markdown ZIP을 만들면 함수 실행 시간과 응답 크기 한도(Risks R7)에 걸리고, 두 형식을 함께 유지해야 합니다. 그래서 JSON 하나만 서버에서 만들고 변환은 앱 밖 스크립트로 합니다."
    *   M: "기술 트레이드오프: shadcn/ui는 접근성 처리를 주지만, 슬라이스 3의 포스트잇 테마를 위해 기본 모양을 덮어써야 합니다. 받아들인 비용은 탭·대화상자·선택창의 키보드와 스크린 리더 동작을 직접 확인하는 것입니다(84행)." 결정을 두 번 바꾼 경위는 브리프에만 둡니다(C17).
    *   N: "범위 결정: Tailwind CSS 학습을 겸합니다. 기술 면에서 CSS 변수 테마는 Tailwind v4 `@theme`로도 같은 방식으로 둘 수 있어(파일 5), CSS Modules가 주는 추가 이점이 작습니다."
    *   O: "범위 결정: 프로젝트를 둘로 나누면 마이그레이션을 두 곳에 적용해야 하고 스키마가 어긋날 수 있습니다. 1인 프로젝트에서 이 관리 비용을 피했습니다. 받아들인 비용은 Risks R8입니다." 기존의 리뷰 반영 문장은 유지합니다.
    *   P: "범위 결정: 임시 저장과 재전송 같은 화면 흐름을 자동으로 확인하는 것과 Playwright 학습을 함께 얻으려고 e2e를 둡니다. 받아들인 비용은 Risks R8입니다."
    *   222행 절 머리에 한 줄을 넣습니다: "이 절의 '범위 결정'은 학습·포트폴리오 목적(Technical Plan 결정 요약)에서 나온 선택입니다."

### [Issue C2] [`structural` `design` `style`] - Severity: Blocker
*   **Affected Scope:** 문서 전체. 위험이 66~74, 141, 151~153, 280~293행에 흩어져 있습니다.
*   **Discrepancy Description:** `Risks & Mitigations` 절이 없습니다. 대응이 비어 있는 위험도 있습니다: 두 글자 검색, 운영 DB e2e, 약관, IndexedDB 대기분 유실, 데이터 손실과 백업 주기.
*   **Rationale:** 표준이 요구하는 필수 항목입니다. 단일 저장소 데이터 손실은 브리프 #6의 핵심 위험이었습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 흩어진 내용을 한곳에 모으면 됩니다. 대응이 없던 것 중 "백업 주기"만 새 운영 규칙이 필요합니다. 주 1회를 기본값으로 제안하며, 사용자가 바꿀 수 있습니다.
*   ***Proposed Edit:***
    *   Location: `## Non-Functional Requirements` 뒤, `## Future Improvements` 앞에 `## Risks & Mitigations`를 새로 둡니다.
    *   Change: 아래 표를 넣습니다. 74행(약관)은 이 표로 옮기고 Open Questions에서 지웁니다.

        | # | 위험 | 영향 | 대응 | 상태 |
        |---|---|---|---|---|
        | R1 | 단일 저장소 데이터 손실(실수 삭제, 마이그레이션 오류, 프로젝트 손상) | 모든 메모 | `pg_dump`를 주 1회 받고, 큰 마이그레이션 전에 추가로 받습니다. 덤프는 PC의 `backup/`(git 제외)에 둡니다. 영구 삭제는 보관함에서 확인을 거쳐야 합니다. | 운영 규칙(슬라이스 0) |
        | R2 | Supabase Free 프로젝트 정지(7일 저활동) | 앱 사용 불가 | 하루 1회 cron 접속 유지 + 화면에 마지막 성공 시각 표시(48시간 경고) | 설계 반영 |
        | R3 | 홈 화면 앱 세션 만료(특히 iOS) | 매번 로그인 → 사용 포기 | 쿠키 세션 7일 게이트, 실패 시 클라이언트 세션으로 전환 | 게이트로 확인 |
        | R4 | 첫 화면이 서버 왕복(Vercel, 필요하면 Auth)을 기다림 | 입력 시작이 늦어짐 | 게이트에서 콜드 스타트 시간을 재서 시험 페이지와 비교합니다. 공통 레이아웃에서 DB 조회를 하지 않습니다. | 게이트로 측정 |
        | R5 | 오프라인·약한 신호에서 앱을 새로 열면 입력창이 없음 | 이동 중 메모 불가 | 받아들입니다(Non-Goal: 완전한 오프라인). 이미 열린 화면의 저장 실패만 임시 저장으로 다룹니다. | 받아들인 한계 |
        | R6 | 브라우저 저장소가 지워지면 전송 대기분 유실 | 아직 서버에 없는 메모 | "전송 대기 N건" 표시로 알아챌 수 있게 합니다. 그 이상은 막지 않습니다. | 받아들인 한계 |
        | R7 | 내보내기 응답 크기 한도(C8) | 탈출 경로 실패 또는 누락 | 건수 대조와 크기 기준(내보내기 절) | 설계 반영 |
        | R8 | 운영 DB에서 e2e 실행 | 정리 코드 오류로 운영 데이터 손상 | 별도 시험 계정, `[e2e]` 접두사 행만 정리, `rls.spec.ts`가 실패하면 중단 | 설계 반영 |
        | R9 | 공개 저장소로 설정 정보 노출(프로젝트 ref, 풀러 주소) | 로그인 시도 대상이 됨 | 가입 차단, RLS, 비밀번호는 비밀번호 관리자가 만든 긴 값을 씁니다. `.env*`와 `backup/`은 git에서 제외합니다. | 설계 반영 |
        | R10 | 두 글자 이하 검색어는 전체 스캔 | 메모가 쌓이면 느려짐 | 슬라이스 0 사용 중 측정. 수천 건에서 체감상 느리면 그때 대책(검색어 최소 길이 등)을 정합니다. | 측정 대기 |
        | R11 | Vercel Hobby 약관(비상업·개인 용도) | 계정 제한 | 작성자 판단. 개인 메모 용도로만 씁니다. | 작성자 판단 |

### [Issue C3] [`structural` `style` `design`] - Severity: Major
*   **Affected Scope:** Lines 248-252 (Alternative L), 220 (Alternative G)
*   **Discrepancy Description:** 채택안이 대안 절에 "Reason for Rejection: 채택"으로 들어 있습니다. 같은 항목 안에서 Cons("위장 가능")와 Reason("실제 위험 아님")이 서로 부정합니다. 실제로 기각한 `service_role`·해시 방식은 별도 항목이 없습니다. G에는 "Rejected"와 "(채택)"이 섞여 있습니다.
*   **Rationale:** Stage 5·6·7에서 연속으로 지적됐습니다. 처음 읽는 사람은 무엇을 버렸는지 알 수 없습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 지적이 맞습니다. 2026-11-29에 제가 고치면서 생긴 구조 문제입니다.
*   ***Proposed Edit:***
    *   Location: 248~252행을 아래 세 항목으로 바꿉니다.
    *   L1 "`service_role` 키로 성공·실패를 기록": Pros는 성공·실패를 모두 남기려는 의도. Cons는 DB 정지로 인한 실패는 같은 DB에 쓸 수 없고, RLS를 우회하는 비밀 키와 유출 검사가 필요함. 사유는 "기술 트레이드오프: 얻는 정보(DB 정지가 아닌 실패의 원인)가 Vercel 로그로도 보이는데, 비용은 최고 권한 키 관리입니다(2026-11-29 변경)."
    *   L2 "DB에 쓰지 않고 로그로만 확인": Cons는 Vercel Hobby 로그 약 1시간, Supabase 로그 24시간이라 화면에 상태를 낼 수 없음. 사유는 Cons 그대로.
    *   L3 "`keepalive()` 안에서 `CRON_SECRET` 해시를 확인해 cron만 기록": Pros는 누가 불렀는지 구분됨. Cons는 비밀을 Vercel과 DB 두 곳에서 관리. 사유는 "구분 정보의 가치가 낮습니다. 화면에 보이는 사실('프로젝트가 활동 중')은 누가 불러도 참입니다. 다만 cron 고장 확인에는 C5의 절차를 씁니다."
    *   채택한 `anon` 방식은 Technical Plan(149~153행)에만 둡니다.
    *   G(220행): "Rejected by author: '분류철 중 하나'로 결정했습니다. 절충안(채택): …"으로 접두어와 채택 표기를 분리합니다.

### [Issue C5] [`design` `style`] - Severity: Major
*   **Affected Scope:** Lines 72, 83, 151, 153, 252 (접속 유지); 구현 계획 350, 496행
*   **Discrepancy Description:** 시험 페이지의 cron도 같은 `keepalive()`를 부르므로, 새 앱의 cron이 돌지 않아도 `last_ok_at`이 매일 바뀝니다. 그러면 슬라이스 0 완료 조건이 거짓으로 통과합니다. 153행은 "API 로그로 확인 가능"이라고 하지만 그 로그는 24시간만 남습니다. "실패 기록 불가"는 DB 정지 말고 다른 실패(`CRON_SECRET` 불일치, 함수 오류)까지 포괄해 너무 넓습니다.
*   **Rationale:** 검증 절차가 증명하려는 것을 증명하지 못합니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 진단용 인자를 추가하는 것보다, 확인 기간에 다른 호출자를 없애는 편이 단순합니다. 시험 페이지는 어차피 B8에서 정리할 대상입니다.
*   ***Proposed Edit:***
    *   153행: "잃는 정보는 '누가 불렀는가'입니다. Supabase API 로그로는 최근 24시간만 확인할 수 있습니다. 그래서 새 앱 cron의 자동 실행은 다른 호출자를 없앤 상태에서 `last_ok_at`으로 확인합니다(슬라이스 0 완료 조건)."
    *   151행, 83행: "DB가 멈추면 같은 DB에 실패를 쓸 수 없고, 그 밖의 실패(`CRON_SECRET` 불일치, 함수 오류)는 Vercel 로그와 `last_ok_at`이 오래된 것으로 알아챕니다." 83행의 "어차피"는 지웁니다.
    *   72행: "실행 기록을 오래 보려면…" 대신 "`last_ok_at`은 DB 활동 기록이며 호출 주체를 증명하지 않습니다"로 고칩니다.
    *   496행(Verification): "확인 전에 시험 페이지의 cron을 끕니다(Vercel 프로젝트 `scattered-notepad-spike`의 cron 비활성화 또는 B8 정리). 그 뒤 며칠 동안 `last_ok_at`이 매일 03:00~04:00 UTC에 바뀌는지 봅니다."
    *   291행: "시험 페이지는 건드리지 않습니다" 뒤에 "단, 슬라이스 0 완료 확인 전에 시험 페이지의 cron은 끕니다"를 붙입니다.

### [Issue C6] [`design` `style`] + Stage 5 R-ZO-2 - Severity: Major
*   **Affected Scope:** Lines 108, 141, 288 (NFR 성능), 172; 구현 계획 409행
*   **Discrepancy Description:** "입력창은 서버 데이터를 기다리지 않고 먼저 그린다"가 SSR + 쿠키 세션 구조와 맞지 않습니다. 첫 HTML이 서버 왕복 뒤에 옵니다. 공통 레이아웃이 `getClaims()`를 한 번 더 하고 상태 배너가 DB를 조회합니다. "속도 목표"라는 말에 수치가 없습니다.
*   **Rationale:** 이 앱의 핵심 사용감(홈 화면에서 바로 입력)이 근거 없이 약속되어 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 정적 셸 구조로 바꾸면 쿠키 세션을 고른 의미가 줄고 범위도 커집니다. 그래서 SSR 대기를 받아들이고, 대신 측정하고 불필요한 왕복을 줄이는 쪽을 제안합니다.
*   ***Proposed Edit:***
    *   288행: "홈 화면 앱을 열면 로그인 화면 없이 입력창이 뜨는 것이 핵심 요구입니다. 첫 화면은 서버에서 그려지므로 서버 왕복을 기다립니다(Risks R4). 입력 화면은 메모 목록 같은 DB 데이터를 기다리지 않고 입력창부터 보여 줍니다. 콜드 스타트에서 입력창이 보일 때까지 걸리는 시간은 쿠키 세션 게이트에서 재서 시험 페이지와 비교하고, 크게 느리면 게이트 실패로 봅니다."
    *   172행: 기록 항목에 "홈 화면 아이콘을 누른 뒤 입력창이 보일 때까지 걸린 시간(초, 앱을 완전히 닫은 상태에서)"을 더합니다.
    *   409행(파일 13): "로그인 확인은 `proxy.ts` 한 곳에서만 합니다. 레이아웃은 `getClaims()`를 다시 부르지 않습니다. 접속 유지 상태는 `/settings`에만 보여 주고, 48시간을 넘긴 경우에만 `/settings` 링크에 경고 표시를 붙입니다(DB 조회는 `/settings`에서만)."
        *   이 수정으로 151행의 "화면 상단에는 마지막 성공 시각을 보여 주고"도 "설정 화면에 마지막 성공 시각을 보여 주고"로 바뀝니다.
        *   48시간 경고를 모든 화면에서 보려면 결국 조회가 필요하므로, 경고는 설정 화면에서만 보입니다. 이것을 받아들입니다.
    *   141행의 오프라인 첫 실행 문장 뒤에 "(Risks R5)"를 붙입니다.

### [Issue C7] [`design`] + Stage 6 10번 - Severity: Major
*   **Affected Scope:** Lines 45, 116, 122-123 (데이터 모델, 상태 모델, 삭제)
*   **Discrepancy Description:** 분류철을 보관하거나 영구 삭제할 때 그 안의 메모가 어떻게 되는지 정의되지 않았습니다. 복합 외래 키의 `on delete` 동작도 정해지지 않았습니다.
*   **Rationale:** 정해 두지 않으면 구현 시점에 임의로 정하게 됩니다. 삭제가 실패하거나 분류 이력이 빠질 수 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 가장 단순한 규칙은 "보관은 분류철만 숨기고 메모는 그대로, 영구 삭제는 빈 분류철만"입니다. 이렇게 하면 메모의 `folder_id`가 바뀌지 않으므로 이력 누락도 생기지 않습니다.
*   ***Proposed Edit:***
    *   123행 뒤에 "**분류철 보관과 삭제**" 항목을 둡니다.
        *   분류철을 보관하면 분류철 목록과 선택창에서만 빠집니다. 안의 메모는 그 분류철에 그대로 남고, 보관된 분류철 목록에서 열어 볼 수 있습니다. 검색 결과에는 분류철 이름과 "보관" 표시가 함께 나옵니다.
        *   `is_todo` 분류철은 보관할 수 없습니다(탭마다 하나뿐이고 체크박스가 여기에 달려 있기 때문).
        *   분류철 영구 삭제는 안에 메모가 하나도 없을 때만 허용합니다. 메모가 있으면 먼저 다른 분류철이나 미분류로 옮겨야 하고, 그 이동은 트리거가 이력으로 남깁니다.
        *   복합 외래 키는 기본 동작(`no action`)을 씁니다.

### [Issue C8] [`design` `style`] - Severity: Major
*   **Affected Scope:** Lines 47, 157, 302
*   **Discrepancy Description:** "수만 건까지 한 번에 응답"이 검증되지 않은 가정입니다. Vercel 함수의 응답 본문 한도(4.5MB)와 PostgREST `max_rows = 1000`이 사양에 없습니다. 완료 시험이 JSON과 Markdown만 비교하므로 JSON 자체가 DB보다 적게 담긴 누락을 잡지 못합니다. 47행의 완료 조건 문구는 157행과 다릅니다.
*   **Rationale:** 탈출 경로가 아무 경고 없이 데이터를 빠뜨릴 수 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 응답 4.5MB 한도는 Vercel Functions 문서에 있는 값으로 알고 있습니다. 구현 전에 공식 문서에서 다시 확인하라는 문장을 함께 넣습니다. 건수 대조는 JSON에 DB 건수를 넣으면 비용이 거의 없습니다.
*   ***Proposed Edit:***
    *   157행의 "수만 건 이하…다시 정합니다"를 다음으로 바꿉니다. "Vercel 함수의 응답 본문은 4.5MB를 넘을 수 없습니다(구현 전 공식 문서 재확인). 메모 1건을 JSON으로 약 0.5KB로 잡으면 약 8,000건이 한도입니다. 그래서 내보낸 파일이 3MB를 넘으면 설정 화면에 경고를 보이고, 나눠 받는 방식(Future Improvements)을 그때 만듭니다. DB는 한 번에 1,000행까지만 돌려주므로(PostgREST `max_rows`), 서버는 1,000건씩 나눠 모두 읽습니다. JSON에는 DB에서 센 테이블별 건수(`counts`)를 함께 넣습니다."
    *   157행의 완료 시험: "변환 스크립트가 `counts`, JSON 배열 길이, 생성한 파일 수를 모두 대조하고, 다르면 실패합니다."
    *   47행: "내보낸 JSON을 Markdown으로 변환해 다른 노트 도구에서 열리고, 건수와 본문 해시가 DB와 일치하는지 확인하는 시험"으로 157행과 같은 말로 맞추고, "형식은 Technical Plan에서 정합니다"를 지웁니다.
    *   302행: "내보낸 파일이 3MB를 넘으면"을 조건으로 적습니다.

### [Issue C9] [`structural` `style`] - Severity: Major
*   **Affected Scope:** Lines 48, 299
*   **Discrepancy Description:** 48행은 `pg_dump`를 "보조 수단"으로 적어, 내보내기가 주 백업처럼 읽힙니다. 299행은 두 수단을 묶어 다룹니다.
*   **Rationale:** 47행과 293행은 "백업은 `pg_dump`가 맡는다"고 하므로 서로 어긋납니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   48행 둘째 문장을 다음으로 바꿉니다. "Supabase Free는 자동 백업이 없으므로 DB 백업은 PC에서 `pg_dump`로 합니다(Risks R1)."
    *   299행을 "마지막 백업·내보내기 시각 표시: `pg_dump`(백업)와 `/api/export`(탈출 경로)는 사람이 기억해서 해야 합니다. 두 시각을 따로 기록하고…"로 고칩니다.

### [Issue C10] [`structural` `style`] - Severity: Major
*   **Affected Scope:** Lines 17-22, 70, 72, 73, 74
*   **Discrepancy Description:** "확인한 것" 목록이 2026-11-23에 멈춰 있습니다. 해결된 항목(70, 72, 73행)이 Open Questions에 남아 있습니다. 22행의 "정지 후 1년 안 복구"는 출처가 없습니다.
*   **Rationale:** 같은 사실이 두 절에 다른 시점으로 적혀 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 22행의 "1년 안 복구"는 브리프에서도 근거를 찾지 못했습니다. 그래서 지우는 쪽을 제안합니다. 출처가 있으면 알려 주세요.
*   ***Proposed Edit:***
    *   17행의 굵은 글씨를 `### 검증 현황`으로 바꾸고, 항목마다 날짜를 붙입니다.
        *   검색(11-23), 가입 차단·RLS·GRANT(11-23), Android 같은 날 세션 유지(11-23), `pg_dump` 백업·복원(11-25), Vercel→Supabase RPC 호출(11-25), cron 자동 실행(11-28).
        *   "공식 문서 확인(2026-11-23)" 소항목: 자동 백업 없음, 7일 저활동 정지. "1년 안 복구"는 지웁니다.
    *   70행(기존 도구 시험 생략)은 Overview 15행에 이미 있으므로 지웁니다.
    *   72, 73행은 `### 검증 현황`으로 옮기고 Open Questions에서 지웁니다.
    *   74행은 Risks R11로 옮깁니다.

### [Issue C11] [`structural`] - Severity: Major
*   **Affected Scope:** Lines 51, 64, 168
*   **Discrepancy Description:** 슬라이스 순서는 실행 계획인데 Goals(51행)와 Non-Goals(64행)에 들어 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Technical Plan의 `### 슬라이스 0의 구성과 첫 단계` 앞에 `### 슬라이스 순서`를 두고 51행 내용을 옮깁니다. 64행은 Non-Goals에 "슬라이스 0의 분류 제안(→ 슬라이스 순서)" 한 줄만 남깁니다.

### [Issue C12] [`structural` `style`] - Severity: Major
*   **Affected Scope:** Line 297
*   **Discrepancy Description:** `### Future Improvements`가 NFR의 하위 절로 들어가 있습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** `## Future Improvements`로 올리고, 새 `## Risks & Mitigations` 뒤에 둡니다.

### [Issue X1] [Stage 5 재검토 `inventive-catalyst`] - Severity: Major
*   **Affected Scope:** 구현 계획 399행(파일 11), 414행(파일 14), 466행(파일 24) — DetailedRange
*   **Discrepancy Description:** 전송 대기 목록을 키 하나(`pending-memos`) 아래 배열 하나로 둡니다. 그래서 `flush`의 `remove(id)`가 배열을 읽고 다시 쓰는 사이에 새 `enqueue`가 끼면 새 항목이 지워집니다. 입력창은 "대기 목록에서 빠지면 지운다"는 규칙이라, 이 메모는 전송 완료로 오인되어 사라집니다. "동시 `flush` 중복 전송 금지"는 서버가 이미 멱등이므로 필요 없는 규칙입니다.
*   **Rationale:** "1탭 저장, 저장 확인 전 입력 유지"(42행) 약속을 깨는 데이터 유실 경로입니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 시나리오를 따라가 보니 실제로 일어날 수 있습니다. 항목마다 키를 따로 두면 경쟁 자체가 사라지고, 코드도 더 단순해집니다.
*   ***Proposed Edit:***
    *   399행: "`idb-keyval`로 항목마다 키 `pending:<id>`를 둡니다(`{id, space, body, createdAt}`). `list()`는 `entries()`에서 `pending:` 키만 골라 `createdAt` 순으로 정렬합니다. `enqueue`와 `remove`는 서로 다른 키만 건드립니다. 중복 전송은 서버의 생성 전용 저장(파일 10)이 무시하므로 막지 않습니다."
    *   466행 시험: "`flush`가 도는 중에 `enqueue`한 항목이 사라지지 않는다"로 바꿉니다. "`flush` 동시 호출 시 중복 전송 없음"은 지웁니다.

### [Issue X2] [Stage 5 재검토 `zoom-out`, Stage 6 4번] - Severity: Major
*   **Affected Scope:** 13, 45, 141행 / 구현 계획 392행(파일 10), 399행, 414행(파일 14)
*   **Discrepancy Description:** 저장할 때마다 분류철 선택창을 띄우면 "질문 없이 저장" 원칙을 되돌리게 됩니다. 또 선택 결과가 대기 항목의 `folderId`로 가는지 `moveMemo`로 가는지, 아직 서버에 없는 메모는 어떻게 되는지가 정의되지 않았습니다.
*   **Rationale:** 브리프 27, 33행도 "확인 단계가 모든 메모에 붙으면 입력이 느려진다"고 지적했습니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   414행: "저장 뒤에는 아무 창도 띄우지 않습니다. 분류는 메모 목록에서 항목을 눌러 합니다(파일 15). 아직 전송 대기 중인 메모는 목록에 '전송 대기' 표시로 보이고 분류할 수 없습니다."
    *   392행: `saveMemo({id, space, body})`. `folderId` 인자를 뺍니다. 새 메모는 항상 미분류로 생성합니다.
    *   399행의 항목 형식에서 `folderId`를 뺍니다.

### [Issue X3] [Stage 6 3번] - Severity: Major
*   **Affected Scope:** 구현 계획 367행(파일 6), 373행(파일 7), 429행(파일 17), 444행(파일 20), 490행 ⑦
*   **Discrepancy Description:** `proxy`의 `matcher`가 `/api/export`와 `offline.html`을 포함하고, 로그인하지 않았으면 `/login`으로 보냅니다. 그래서 "`/api/export`는 미로그인 시 401"이라는 내용에 도달할 수 없습니다. 오프라인 안내 페이지도 리다이렉트될 수 있습니다.
*   **Rationale:** 문서 안의 직접 모순입니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   367행: `matcher`에서 `offline.html`도 뺍니다.
    *   373행: "로그인하지 않았을 때 `/login`으로 보내는 것은 화면 경로에만 합니다. `/api/*`는 보내지 않고 그대로 통과시켜, 라우트가 401을 돌려줍니다."

### [Issue X4] [Stage 6 6번] - Severity: Major
*   **Affected Scope:** Line 49
*   **Discrepancy Description:** "2026-09 이후 날짜가 있는 메모만 살리고, 날짜가 없는 메모는 작성일을 비워 두며"는 날짜 없는 메모를 버린다는 뜻으로도 읽힙니다.
*   **Rationale:** 브리프 36행과 121행의 결정은 "날짜 없는 메모도 가져오고 작성일을 비운다, 2026-09 컷오프는 날짜가 있는 메모에만"입니다.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 49행을 다음으로 고칩니다. "날짜가 있는 메모는 2026-09 이후 것만 가져오고, 날짜가 없는 메모는 모두 가져오되 작성일을 비워 둡니다(`written_at_source = 'none'`). 날짜를 내용에서 추정한 경우만 `'estimated'`로 표시합니다."

### [Issue C13] [`structural`] - Severity: Nit
*   **Affected Scope:** 7, 184, 202, 208, 252, 278, 282, 287, 290, 295, 304행
*   ***AI Suggestion:*** PROPOSE FIX (헤더와 접두어만)
*   ***Proposed Edit:*** NFR의 세 하위 구분을 `###`로 바꿉니다. 기각 사유 접두어는 "Rejected (작성자 결정):", "Rejected (리뷰 후):", "Rejected:"의 의미를 유지하되 C1 형식으로 통일합니다. 구분선은 메타데이터 아래(7행)와 Detailed Implementation Plan 앞만 남기고 나머지는 지웁니다.

### [Issue C14] [`structural`] - Severity: Nit
*   **Affected Scope:** 93-105행
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 상자의 오른쪽 테두리 `│`와 `┐┘`를 없애고 왼쪽 테두리만 남깁니다. 전각 문자 폭에 영향받지 않게 됩니다.

### [Issue C15] [`structural`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 3~5행에 `*   **Last Updated:** 2026-11-29 (egm-review Stage 5~7 반영)`을 추가합니다.

### [Issue C16] [`structural`] + Stage 6 5번 - Severity: Nit (Stage 6에서는 Major)
*   **Affected Scope:** 85, 159-166, 286행 / 구현 계획 454행
*   **Discrepancy Description:** 상호 참조에 링크가 없습니다. 비밀 파일 위치가 166행(`.env`만)과 454행(`.env.local`, `.env.test.local`)에서 서로 다릅니다. 환경 변수 표에 `E2E_*`가 없고, `backup/`이 정의되지 않았습니다.
*   ***AI Suggestion:*** PROPOSE FIX (비밀 파일 부분만). 상호 참조 링크는 DECLINE: 같은 문서 안 이름 참조라 찾을 수 있습니다.
*   ***Proposed Edit:*** 166행을 다음 표로 바꿉니다.

    | 파일 | 위치 | 내용 | git |
    |---|---|---|---|
    | `.env` | `C:\mygit\pjy-dir\` | `PGPASSWORD`(`pg_dump`용) | 제외 |
    | `backup/` | `C:\mygit\pjy-dir\` | `pg_dump` 덤프 파일 | 제외 |
    | `.env.local` | `scattered-notepad\` | `NEXT_PUBLIC_SUPABASE_*`, `CRON_SECRET` | 제외 |
    | `.env.test.local` | `scattered-notepad\` | `E2E_USER_EMAIL`, `E2E_USER_PASSWORD` | 제외 |

    환경 변수 표에 `E2E_USER_EMAIL`, `E2E_USER_PASSWORD`(비밀, e2e와 시험 계정 전용)를 추가합니다.

### [Issue C17] [`style`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 84행에서 "처음에 Tailwind를 골랐다가…되돌렸습니다" 문장을 지웁니다. 83행의 "처음에는 `service_role`…바꿨습니다"는 "(기각한 방식은 Alternative L1~L3)"로 줄입니다.

### [Issue C18] [`style`] - Severity: Nit
*   **Discrepancy Description:** 같은 내용이 반복됩니다(옮기면 된다, 두 글자 검색, iOS 미시험, 방어적 문구).
*   ***AI Suggestion:*** DECLINE
*   ***Justification:*** C10, C2를 반영하면 70, 74행이 빠지면서 일부가 자연히 줄어듭니다. 나머지 반복은 각 절을 따로 읽을 때 필요한 맥락입니다.

### [Issue C19] [`style`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 208행을 다음으로 바꿉니다. "Rejected: Supabase는 로그인, RLS, 검색(`pg_trgm`)을 한 서비스에서 제공합니다. DB 할당량 500MB는 메모 1건 1KB로 잡아도 수십만 건 분량입니다(2026-11-23 공식 문서)."

### [Issue C20] [`style` `design`] + Stage 6 8번 - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   45행 "학습 이력"을 "분류 이력(`classification_events`, 메모를 통해 탭이 정해짐)"으로 바꿉니다.
    *   218행 Pros의 "리뷰어 전원이 권했습니다"를 Reason 칸으로 옮깁니다.
    *   34행을 "성공 기준: 슬라이스 0을 쓰기 시작하고 한 달 뒤에 아래 두 가지를 확인합니다."로 바꿉니다.

### [Issue C21] [`design`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 37행 뒤에 다음을 넣습니다. "측정: 작성자가 한 달 동안 매주 금요일에 세 곳에 새로 적은 메모 수와 완료 목록 참고 여부를 `tasklist.md`에 직접 기록합니다."

### [Issue C22] [`design`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** 트리거가 insert에서는 동작하지 않는다는 점이 오히려 가져오기 이벤트가 섞이지 않게 해 줍니다. 이 점을 문서에 적어 두면 됩니다.
*   ***Proposed Edit:*** 118행에 추가합니다. "트리거는 분류철 변경(`update`)에서만 동작하므로, 처음부터 분류철을 지정해 넣는 가져오기(슬라이스 1)는 이력을 남기지 않습니다. 가져온 뒤의 일괄 정리를 이력에서 구분하는 방법은 슬라이스 2 설계에서 정합니다."

### [Issue C23] [`design`] - Severity: Nit
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** 141행에 다음을 추가합니다. "드물게, 저장은 됐지만 응답을 잃은 메모를 사용자가 영구 삭제한 뒤 재전송이 도착하면 그 메모가 다시 생깁니다. 받아들이는 한계입니다."

### [DECLINE 기록]
*   **C16의 상호 참조 링크**: 위 C16에 적은 이유로 고치지 않습니다.
*   **C18 반복 문구**: 위에 적은 이유로 고치지 않습니다.
*   **Stage 5 재검토 Nit 중 이번 범위 밖 항목**: R-ZO-4(`written_at_source` UI), R-ZO-5(`sort_order`), R-ZO-6(key-value 테이블), R-ZO-9(`format.ts`), R-ZO-10(`/folders` 화면 목록), R-IC-1(오프라인 입력 폼), R-IC-3(JSON 가져오기로 `pg_dump` 대체), R-IC-4(GitHub Actions 두 번째 호출자). 이 항목들은 Stage 9(구현 준비도)에서 다시 나오면 그때 다룹니다.
    *   R-IC-1은 C2의 R5로 "받아들인 한계"로 기록합니다.
    *   R-IC-3의 `PGPASSWORD` 평문 보관은 tasklist B8의 "비밀번호 재설정"과 R1의 운영 규칙으로 일부만 다룹니다.
