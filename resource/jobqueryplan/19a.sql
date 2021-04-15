SELECT MIN(n.name) AS voicing_actress,
       MIN(t.title) AS voiced_movie
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND it.info = 'release dates'
  AND mc.note IS NOT NULL
  AND (mc.note LIKE '%(USA)%'
       OR mc.note LIKE '%(worldwide)%')
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%200%'
       OR mi.info LIKE 'USA:%200%')
  AND n.gender = 'f'
  AND n.name LIKE '%Ang%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2005 AND 2009
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND mc.movie_id = ci.movie_id
  AND mc.movie_id = mi.movie_id
  AND mi.movie_id = ci.movie_id
  AND cn.id = mc.company_id
  AND it.id = mi.info_type_id
  AND n.id = ci.person_id
  AND rt.id = ci.role_id
  AND n.id = an.person_id
  AND ci.person_id = an.person_id
  AND chn.id = ci.person_role_id;



Aggregate  (cost=85172.70..85172.71 rows=1 width=64)
  ->  Nested Loop  (cost=1004.44..85172.70 rows=1 width=32)
        ->  Nested Loop  (cost=1004.30..85172.52 rows=1 width=36)
              Join Filter: (t.id = mi.movie_id)
              ->  Nested Loop  (cost=1003.86..85144.47 rows=1 width=44)
                    ->  Nested Loop  (cost=1003.44..85143.28 rows=1 width=48)
                          Join Filter: (t.id = mc.movie_id)
                          ->  Nested Loop  (cost=1003.01..85140.55 rows=1 width=40)
                                ->  Gather  (cost=1002.58..85139.12 rows=1 width=44)
                                      Workers Planned: 2
                                      ->  Nested Loop  (cost=2.58..84139.02 rows=1 width=44)
                                            ->  Hash Join  (cost=2.15..84136.22 rows=2 width=23)
                                                  Hash Cond: (ci.role_id = rt.id)
                                                  ->  Nested Loop  (cost=0.99..84134.98 rows=19 width=27)
                                                        Join Filter: (n.id = ci.person_id)
                                                        ->  Nested Loop  (cost=0.42..82142.98 rows=8 width=23)
                                                              ->  Parallel Seq Scan on name n  (cost=0.00..81659.82 rows=39 width=19)
                                                                    Filter: (((name)::text ~~ '%Ang%'::text) AND ((gender)::text = 'f'::text))
                                                              ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..12.37 rows=2 width=4)
                                                                    Index Cond: (person_id = n.id)
                                                        ->  Index Scan using person_id_cast_info on cast_info ci  (cost=0.56..248.85 rows=12 width=16)
                                                              Index Cond: (person_id = an.person_id)
                                                              Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                                  ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                                        ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                              Filter: ((role)::text = 'actress'::text)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..1.40 rows=1 width=21)
                                                  Index Cond: (id = ci.movie_id)
                                                  Filter: ((production_year >= 2005) AND (production_year <= 2009))
                                ->  Index Only Scan using char_name_pkey on char_name chn  (cost=0.43..1.43 rows=1 width=4)
                                      Index Cond: (id = ci.person_role_id)
                          ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.72 rows=1 width=8)
                                Index Cond: (movie_id = ci.movie_id)
                                Filter: ((note IS NOT NULL) AND (((note)::text ~~ '%(USA)%'::text) OR ((note)::text ~~ '%(worldwide)%'::text)))
                    ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.19 rows=1 width=4)
                          Index Cond: (id = mc.company_id)
                          Filter: ((country_code)::text = '[us]'::text)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..28.03 rows=1 width=8)
                    Index Cond: (movie_id = ci.movie_id)
                    Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%200%'::text) OR ((info)::text ~~ 'USA:%200%'::text)))
        ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
              Index Cond: (id = mi.info_type_id)
              Filter: ((info)::text = 'release dates'::text)
