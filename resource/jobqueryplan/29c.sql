SELECT MIN(chn.name) AS voiced_char,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS voiced_animation
FROM aka_name AS an,
     complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     info_type AS it,
     info_type AS it1,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     name AS n,
     person_info AS pi,
     role_type AS rt,
     title AS t
WHERE cct1.kind = 'cast'
  AND cct2.kind = 'complete+verified'
  AND ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND it.info = 'release dates'
  AND it1.info = 'trivia'
  AND k.keyword = 'computer-animation'
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%200%'
       OR mi.info LIKE 'USA:%200%')
  AND n.gender = 'f'
  AND n.name LIKE '%An%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2000 AND 2010
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND t.id = cc.movie_id
  AND mc.movie_id = ci.movie_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mk.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi.movie_id = ci.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi.movie_id = cc.movie_id
  AND ci.movie_id = mk.movie_id
  AND ci.movie_id = cc.movie_id
  AND mk.movie_id = cc.movie_id
  AND cn.id = mc.company_id
  AND it.id = mi.info_type_id
  AND n.id = ci.person_id
  AND rt.id = ci.role_id
  AND n.id = an.person_id
  AND ci.person_id = an.person_id
  AND chn.id = ci.person_role_id
  AND n.id = pi.person_id
  AND ci.person_id = pi.person_id
  AND it1.id = pi.info_type_id
  AND k.id = mk.keyword_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;



Aggregate  (cost=4242.76..4242.77 rows=1 width=96)
  ->  Nested Loop  (cost=11.20..4242.76 rows=1 width=48)
        Join Filter: (cc.subject_id = cct1.id)
        ->  Nested Loop  (cost=11.20..4241.69 rows=1 width=52)
              Join Filter: (ci.person_id = n.id)
              ->  Nested Loop  (cost=10.77..4239.50 rows=1 width=49)
                    ->  Nested Loop  (cost=10.34..4237.28 rows=1 width=37)
                          Join Filter: (it.id = mi.info_type_id)
                          ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                Filter: ((info)::text = 'release dates'::text)
                          ->  Nested Loop  (cost=10.34..4234.85 rows=1 width=41)
                                Join Filter: (t.id = mi.movie_id)
                                ->  Nested Loop  (cost=9.90..4190.88 rows=1 width=57)
                                      ->  Nested Loop  (cost=9.48..4188.86 rows=1 width=61)
                                            Join Filter: (it1.id = pi.info_type_id)
                                            ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'trivia'::text)
                                            ->  Nested Loop  (cost=9.48..4185.83 rows=49 width=65)
                                                  ->  Nested Loop  (cost=9.05..4147.82 rows=2 width=57)
                                                        Join Filter: (t.id = mc.movie_id)
                                                        ->  Nested Loop  (cost=8.62..4138.12 rows=2 width=49)
                                                              ->  Nested Loop  (cost=8.20..4135.21 rows=1 width=45)
                                                                    Join Filter: (rt.id = ci.role_id)
                                                                    ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                                          Filter: ((role)::text = 'actress'::text)
                                                                    ->  Nested Loop  (cost=8.20..4134.04 rows=1 width=49)
                                                                          Join Filter: (t.id = ci.movie_id)
                                                                          ->  Nested Loop  (cost=7.63..3938.55 rows=4 width=33)
                                                                                Join Filter: (cc.status_id = cct2.id)
                                                                                ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                                                                      Filter: ((kind)::text = 'complete+verified'::text)
                                                                                ->  Nested Loop  (cost=7.63..3937.28 rows=18 width=37)
                                                                                      ->  Nested Loop  (cost=7.20..3841.99 rows=45 width=16)
                                                                                            ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                                                                                                  ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                                                                                        Filter: ((keyword)::text = 'computer-animation'::text)
                                                                                                  ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                                                                                        Recheck Cond: (keyword_id = k.id)
                                                                                                        ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                                              Index Cond: (keyword_id = k.id)
                                                                                            ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..2.77 rows=2 width=12)
                                                                                                  Index Cond: (movie_id = mk.movie_id)
                                                                                      ->  Index Scan using title_pkey on title t  (cost=0.43..2.12 rows=1 width=21)
                                                                                            Index Cond: (id = mk.movie_id)
                                                                                            Filter: ((production_year >= 2000) AND (production_year <= 2010))
                                                                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..48.86 rows=1 width=16)
                                                                                Index Cond: (movie_id = mk.movie_id)
                                                                                Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                                              ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..2.90 rows=2 width=4)
                                                                    Index Cond: (person_id = ci.person_id)
                                                        ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..4.79 rows=5 width=8)
                                                              Index Cond: (movie_id = mk.movie_id)
                                                  ->  Index Scan using person_id_person_info on person_info pi  (cost=0.43..18.76 rows=24 width=8)
                                                        Index Cond: (person_id = ci.person_id)
                                      ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..2.03 rows=1 width=4)
                                            Index Cond: (id = mc.company_id)
                                            Filter: ((country_code)::text = '[us]'::text)
                                ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..43.96 rows=1 width=8)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%200%'::text) OR ((info)::text ~~ 'USA:%200%'::text)))
                    ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..2.22 rows=1 width=20)
                          Index Cond: (id = ci.person_role_id)
              ->  Index Scan using name_pkey on name n  (cost=0.43..2.19 rows=1 width=19)
                    Index Cond: (id = pi.person_id)
                    Filter: (((name)::text ~~ '%An%'::text) AND ((gender)::text = 'f'::text))
        ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
              Filter: ((kind)::text = 'cast'::text)
