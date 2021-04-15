SELECT MIN(mi.info) AS release_date,
       MIN(t.title) AS internet_movie
FROM aka_title AS AT,
     company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     title AS t
WHERE cn.country_code = '[us]'
  AND it1.info = 'release dates'
  AND mc.note LIKE '%(200%)%'
  AND mc.note LIKE '%(worldwide)%'
  AND mi.note LIKE '%internet%'
  AND mi.info LIKE 'USA:% 200%'
  AND t.production_year > 2000
  AND t.id = at.movie_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = at.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = at.movie_id
  AND mc.movie_id = at.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id;



Finalize Aggregate  (cost=52761.54..52761.55 rows=1 width=64)
  ->  Gather  (cost=52761.32..52761.53 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=51761.32..51761.33 rows=1 width=64)
              ->  Nested Loop  (cost=5353.94..51761.28 rows=7 width=60)
                    ->  Nested Loop  (cost=5353.52..51758.21 rows=7 width=64)
                          ->  Nested Loop  (cost=5353.09..51756.43 rows=1 width=76)
                                ->  Nested Loop  (cost=5352.95..51756.12 rows=1 width=80)
                                      ->  Nested Loop  (cost=5352.82..51755.96 rows=1 width=84)
                                            ->  Nested Loop  (cost=5352.38..49017.87 rows=1366 width=33)
                                                  ->  Nested Loop  (cost=5351.95..46685.72 rows=2521 width=12)
                                                        ->  Parallel Hash Join  (cost=5351.53..40475.06 rows=3669 width=8)
                                                              Hash Cond: (mc.company_id = cn.id)
                                                              ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..35097.06 rows=10085 width=12)
                                                                    Filter: (((note)::text ~~ '%(200%)%'::text) AND ((note)::text ~~ '%(worldwide)%'::text))
                                                              ->  Parallel Hash  (cost=4722.92..4722.92 rows=50289 width=4)
                                                                    ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=50289 width=4)
                                                                          Filter: ((country_code)::text = '[us]'::text)
                                                        ->  Index Only Scan using movie_id_aka_title on aka_title at  (cost=0.42..1.66 rows=3 width=4)
                                                              Index Cond: (movie_id = mc.movie_id)
                                                  ->  Index Scan using title_pkey on title t  (cost=0.43..0.93 rows=1 width=21)
                                                        Index Cond: (id = at.movie_id)
                                                        Filter: (production_year > 2000)
                                            ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.99 rows=1 width=51)
                                                  Index Cond: (movie_id = t.id)
                                                  Filter: (((note)::text ~~ '%internet%'::text) AND ((info)::text ~~ 'USA:% 200%'::text))
                                      ->  Index Only Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                                            Index Cond: (id = mc.company_type_id)
                                ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.23 rows=1 width=4)
                                      Index Cond: (id = mi.info_type_id)
                                      Filter: ((info)::text = 'release dates'::text)
                          ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.33 rows=45 width=8)
                                Index Cond: (movie_id = t.id)
                    ->  Index Only Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
                          Index Cond: (id = mk.keyword_id)
