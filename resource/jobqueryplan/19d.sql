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
  AND n.gender = 'f'
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



Finalize Aggregate  (cost=278281.27..278281.28 rows=1 width=64)
  ->  Gather  (cost=278281.05..278281.26 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=277281.05..277281.06 rows=1 width=64)
              ->  Nested Loop  (cost=135324.12..277275.93 rows=1025 width=32)
                    ->  Nested Loop  (cost=135323.70..276550.67 rows=441 width=40)
                          ->  Nested Loop  (cost=135323.27..275140.82 rows=1211 width=44)
                                Join Filter: (t.id = mc.movie_id)
                                ->  Hash Join  (cost=135322.85..274489.26 rows=244 width=52)
                                      Hash Cond: (mi.info_type_id = it.id)
                                      ->  Nested Loop  (cost=135320.42..274411.69 rows=27592 width=56)
                                            ->  Nested Loop  (cost=135319.98..225096.98 rows=1760 width=48)
                                                  ->  Nested Loop  (cost=135319.55..219910.95 rows=3638 width=52)
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
                                                        ->  Index Scan using name_pkey on name n  (cost=0.43..1.53 rows=1 width=19)
                                                              Index Cond: (id = ci.person_id)
                                                              Filter: ((gender)::text = 'f'::text)
                                                  ->  Index Only Scan using char_name_pkey on char_name chn  (cost=0.43..1.43 rows=1 width=4)
                                                        Index Cond: (id = ci.person_role_id)
                                            ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..27.59 rows=43 width=8)
                                                  Index Cond: (movie_id = t.id)
                                      ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                            ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'release dates'::text)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.61 rows=5 width=8)
                                      Index Cond: (movie_id = mi.movie_id)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.16 rows=1 width=4)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..1.62 rows=2 width=4)
                          Index Cond: (person_id = n.id)
