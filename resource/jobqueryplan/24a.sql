SELECT MIN(chn.name) AS voiced_char_name,
       MIN(n.name) AS voicing_actress_name,
       MIN(t.title) AS voiced_action_movie_jap_eng
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     info_type AS it,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND it.info = 'release dates'
  AND k.keyword IN ('hero',
                    'martial-arts',
                    'hand-to-hand-combat')
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%201%'
       OR mi.info LIKE 'USA:%201%')
  AND n.gender = 'f'
  AND n.name LIKE '%An%'
  AND rt.role = 'actress'
  AND t.production_year > 2010
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND mc.movie_id = ci.movie_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mk.movie_id
  AND mi.movie_id = ci.movie_id
  AND mi.movie_id = mk.movie_id
  AND ci.movie_id = mk.movie_id
  AND cn.id = mc.company_id
  AND it.id = mi.info_type_id
  AND n.id = ci.person_id
  AND rt.id = ci.role_id
  AND n.id = an.person_id
  AND ci.person_id = an.person_id
  AND chn.id = ci.person_role_id
  AND k.id = mk.keyword_id;



Aggregate  (cost=6863.36..6863.37 rows=1 width=96)
  ->  Nested Loop  (cost=10.35..6863.35 rows=1 width=48)
        ->  Nested Loop  (cost=9.93..6861.88 rows=1 width=52)
              Join Filter: (t.id = mc.movie_id)
              ->  Nested Loop  (cost=9.50..6858.42 rows=1 width=64)
                    Join Filter: (n.id = an.person_id)
                    ->  Nested Loop  (cost=9.07..6856.32 rows=1 width=72)
                          Join Filter: (rt.id = ci.role_id)
                          ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                Filter: ((role)::text = 'actress'::text)
                          ->  Nested Loop  (cost=9.07..6855.15 rows=1 width=76)
                                ->  Nested Loop  (cost=8.64..6853.45 rows=1 width=64)
                                      ->  Nested Loop  (cost=8.21..6851.64 rows=1 width=45)
                                            Join Filter: (t.id = ci.movie_id)
                                            ->  Nested Loop  (cost=7.65..6810.77 rows=1 width=29)
                                                  Join Filter: (it.id = mi.info_type_id)
                                                  ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                        Filter: ((info)::text = 'release dates'::text)
                                                  ->  Nested Loop  (cost=7.65..6808.34 rows=2 width=33)
                                                        Join Filter: (t.id = mi.movie_id)
                                                        ->  Nested Loop  (cost=7.21..6274.03 rows=16 width=25)
                                                              ->  Nested Loop  (cost=6.78..6114.56 rows=101 width=4)
                                                                    ->  Seq Scan on keyword k  (cost=0.00..2793.84 rows=3 width=4)
                                                                          Filter: ((keyword)::text = ANY ('{hero,martial-arts,hand-to-hand-combat}'::text[]))
                                                                    ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1103.88 rows=303 width=8)
                                                                          Recheck Cond: (keyword_id = k.id)
                                                                          ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                Index Cond: (keyword_id = k.id)
                                                              ->  Index Scan using title_pkey on title t  (cost=0.43..1.58 rows=1 width=21)
                                                                    Index Cond: (id = mk.movie_id)
                                                                    Filter: (production_year > 2010)
                                                        ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..33.38 rows=1 width=8)
                                                              Index Cond: (movie_id = mk.movie_id)
                                                              Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%201%'::text) OR ((info)::text ~~ 'USA:%201%'::text)))
                                            ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..40.85 rows=1 width=16)
                                                  Index Cond: (movie_id = mk.movie_id)
                                                  Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                      ->  Index Scan using name_pkey on name n  (cost=0.43..1.81 rows=1 width=19)
                                            Index Cond: (id = ci.person_id)
                                            Filter: (((name)::text ~~ '%An%'::text) AND ((gender)::text = 'f'::text))
                                ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..1.71 rows=1 width=20)
                                      Index Cond: (id = ci.person_role_id)
                    ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..2.08 rows=2 width=4)
                          Index Cond: (person_id = ci.person_id)
              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..3.39 rows=5 width=8)
                    Index Cond: (movie_id = mk.movie_id)
        ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.47 rows=1 width=4)
              Index Cond: (id = mc.company_id)
              Filter: ((country_code)::text = '[us]'::text)
