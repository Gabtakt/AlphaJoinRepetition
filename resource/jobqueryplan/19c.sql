SELECT MIN(n.name) AS voicing_actress,
       MIN(t.title) AS jap_engl_voiced_movie
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
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%200%'
       OR mi.info LIKE 'USA:%200%')
  AND n.gender = 'f'
  AND n.name LIKE '%An%'
  AND rt.role = 'actress'
  AND t.production_year > 2000
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



Aggregate  (cost=223143.64..223143.65 rows=1 width=64)
  ->  Nested Loop  (cost=136324.12..223143.63 rows=2 width=32)
        Join Filter: (n.id = an.person_id)
        ->  Gather  (cost=136323.70..223141.98 rows=1 width=40)
              Workers Planned: 2
              ->  Nested Loop  (cost=135323.70..222141.88 rows=1 width=40)
                    ->  Nested Loop  (cost=135323.27..222140.71 rows=1 width=44)
                          ->  Hash Join  (cost=135322.85..222138.00 rows=1 width=52)
                                Hash Cond: (mi.info_type_id = it.id)
                                ->  Nested Loop  (cost=135320.42..222135.52 rows=23 width=56)
                                      ->  Nested Loop  (cost=135319.98..220160.67 rows=71 width=48)
                                            ->  Nested Loop  (cost=135319.55..219951.12 rows=147 width=52)
                                                  ->  Hash Join  (cost=135319.12..195251.19 rows=16068 width=33)
                                                        Hash Cond: (t.id = ci.movie_id)
                                                        ->  Parallel Seq Scan on title t  (cost=0.00..49166.29 rows=570735 width=21)
                                                              Filter: (production_year > 2000)
                                                        ->  Hash  (cost=134081.38..134081.38 rows=71180 width=12)
                                                              ->  Nested Loop  (cost=0.56..134081.38 rows=71180 width=12)
                                                                    ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                                          Filter: ((role)::text = 'actress'::text)
                                                                    ->  Index Scan using role_id_cast_info on cast_info ci  (cost=0.56..133303.71 rows=77651 width=16)
                                                                          Index Cond: (role_id = rt.id)
                                                                          Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                                  ->  Index Scan using name_pkey on name n  (cost=0.43..1.54 rows=1 width=19)
                                                        Index Cond: (id = ci.person_id)
                                                        Filter: (((name)::text ~~ '%An%'::text) AND ((gender)::text = 'f'::text))
                                            ->  Index Only Scan using char_name_pkey on char_name chn  (cost=0.43..1.43 rows=1 width=4)
                                                  Index Cond: (id = ci.person_role_id)
                                      ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..27.80 rows=1 width=8)
                                            Index Cond: (movie_id = t.id)
                                            Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%200%'::text) OR ((info)::text ~~ 'USA:%200%'::text)))
                                ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                      ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                            Filter: ((info)::text = 'release dates'::text)
                          ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.66 rows=5 width=8)
                                Index Cond: (movie_id = t.id)
                    ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.16 rows=1 width=4)
                          Index Cond: (id = mc.company_id)
                          Filter: ((country_code)::text = '[us]'::text)
        ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..1.63 rows=2 width=4)
              Index Cond: (person_id = ci.person_id)
