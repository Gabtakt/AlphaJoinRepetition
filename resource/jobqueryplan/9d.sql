SELECT MIN(an.name) AS alternative_name,
       MIN(chn.name) AS voiced_char_name,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS american_movie
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND n.gender = 'f'
  AND rt.role = 'actress'
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND ci.movie_id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND n.id = ci.person_id
  AND chn.id = ci.person_role_id
  AND an.person_id = n.id
  AND an.person_id = ci.person_id;



Finalize Aggregate  (cost=211092.82..211092.83 rows=1 width=128)
  ->  Gather  (cost=211092.59..211092.80 rows=2 width=128)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=210092.59..210092.60 rows=1 width=128)
              ->  Nested Loop  (cost=140672.37..210016.74 rows=7585 width=64)
                    ->  Nested Loop  (cost=140671.95..208260.78 rows=3259 width=56)
                          Join Filter: (ci.movie_id = t.id)
                          ->  Nested Loop  (cost=140671.52..206547.13 rows=3259 width=47)
                                ->  Nested Loop  (cost=140671.09..202113.29 rows=6733 width=35)
                                      ->  Hash Join  (cost=140670.66..179393.10 rows=29740 width=16)
                                            Hash Cond: (mc.movie_id = ci.movie_id)
                                            ->  Parallel Hash Join  (cost=5351.53..37866.69 rows=395501 width=4)
                                                  Hash Cond: (mc.company_id = cn.id)
                                                  ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..29661.37 rows=1087137 width=8)
                                                  ->  Parallel Hash  (cost=4722.92..4722.92 rows=50289 width=4)
                                                        ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=50289 width=4)
                                                              Filter: ((country_code)::text = '[us]'::text)
                                            ->  Hash  (cost=134081.38..134081.38 rows=71180 width=12)
                                                  ->  Nested Loop  (cost=0.56..134081.38 rows=71180 width=12)
                                                        ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                              Filter: ((role)::text = 'actress'::text)
                                                        ->  Index Scan using role_id_cast_info on cast_info ci  (cost=0.56..133303.71 rows=77651 width=16)
                                                              Index Cond: (role_id = rt.id)
                                                              Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                      ->  Index Scan using name_pkey on name n  (cost=0.43..0.76 rows=1 width=19)
                                            Index Cond: (id = ci.person_id)
                                            Filter: ((gender)::text = 'f'::text)
                                ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.66 rows=1 width=20)
                                      Index Cond: (id = ci.person_role_id)
                          ->  Index Scan using title_pkey on title t  (cost=0.43..0.51 rows=1 width=21)
                                Index Cond: (id = mc.movie_id)
                    ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..0.52 rows=2 width=20)
                          Index Cond: (person_id = n.id)
