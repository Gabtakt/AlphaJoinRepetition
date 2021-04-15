SELECT MIN(n.name) AS voicing_actress,
       MIN(t.title) AS kung_fu_panda
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
WHERE ci.note = '(voice)'
  AND cn.country_code = '[us]'
  AND it.info = 'release dates'
  AND mc.note LIKE '%(200%)%'
  AND (mc.note LIKE '%(USA)%'
       OR mc.note LIKE '%(worldwide)%')
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%2007%'
       OR mi.info LIKE 'USA:%2008%')
  AND n.gender = 'f'
  AND n.name LIKE '%Angel%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2007 AND 2008
  AND t.title LIKE '%Kung%Fu%Panda%'
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



Aggregate  (cost=55701.96..55701.97 rows=1 width=64)
  ->  Nested Loop  (cost=1003.41..55701.95 rows=1 width=32)
        ->  Nested Loop  (cost=1003.28..55701.78 rows=1 width=36)
              Join Filter: (ci.person_id = n.id)
              ->  Nested Loop  (cost=1002.85..55700.24 rows=1 width=29)
                    ->  Nested Loop  (cost=1002.70..55700.06 rows=1 width=33)
                          Join Filter: (t.id = mi.movie_id)
                          ->  Nested Loop  (cost=1002.27..55671.88 rows=1 width=41)
                                ->  Nested Loop  (cost=1001.85..55670.61 rows=1 width=45)
                                      ->  Nested Loop  (cost=1001.42..55668.95 rows=1 width=41)
                                            ->  Nested Loop  (cost=1001.00..55667.49 rows=1 width=45)
                                                  Join Filter: (t.id = ci.movie_id)
                                                  ->  Gather  (cost=1000.43..55624.97 rows=1 width=29)
                                                        Workers Planned: 2
                                                        ->  Nested Loop  (cost=0.43..54624.87 rows=1 width=29)
                                                              ->  Parallel Seq Scan on title t  (cost=0.00..54433.61 rows=9 width=21)
                                                                    Filter: ((production_year >= 2007) AND (production_year <= 2008) AND ((title)::text ~~ '%Kung%Fu%Panda%'::text))
                                                              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..21.24 rows=1 width=8)
                                                                    Index Cond: (movie_id = t.id)
                                                                    Filter: (((note)::text ~~ '%(200%)%'::text) AND (((note)::text ~~ '%(USA)%'::text) OR ((note)::text ~~ '%(worldwide)%'::text)))
                                                  ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..42.51 rows=1 width=16)
                                                        Index Cond: (movie_id = mc.movie_id)
                                                        Filter: ((note)::text = '(voice)'::text)
                                            ->  Index Only Scan using char_name_pkey on char_name chn  (cost=0.43..1.46 rows=1 width=4)
                                                  Index Cond: (id = ci.person_role_id)
                                      ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..1.64 rows=2 width=4)
                                            Index Cond: (person_id = ci.person_id)
                                ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.26 rows=1 width=4)
                                      Index Cond: (id = mc.company_id)
                                      Filter: ((country_code)::text = '[us]'::text)
                          ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..28.17 rows=1 width=8)
                                Index Cond: (movie_id = ci.movie_id)
                                Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%2007%'::text) OR ((info)::text ~~ 'USA:%2008%'::text)))
                    ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
                          Index Cond: (id = mi.info_type_id)
                          Filter: ((info)::text = 'release dates'::text)
              ->  Index Scan using name_pkey on name n  (cost=0.43..1.53 rows=1 width=19)
                    Index Cond: (id = an.person_id)
                    Filter: (((name)::text ~~ '%Angel%'::text) AND ((gender)::text = 'f'::text))
        ->  Index Scan using role_type_pkey on role_type rt  (cost=0.14..0.16 rows=1 width=4)
              Index Cond: (id = ci.role_id)
              Filter: ((role)::text = 'actress'::text)
