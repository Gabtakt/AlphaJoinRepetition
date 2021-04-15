SELECT MIN(cn1.name) AS first_company,
       MIN(cn.name) AS second_company,
       MIN(mi_idx1.info) AS first_rating,
       MIN(mi_idx.info) AS second_rating,
       MIN(t1.title) AS first_movie,
       MIN(t.title) AS second_movie
FROM company_name AS cn1,
     company_name AS cn,
     info_type AS it1,
     info_type AS it,
     kind_type AS kt1,
     kind_type AS kt,
     link_type AS lt,
     movie_companies AS mc1,
     movie_companies AS mc,
     movie_info_idx AS mi_idx1,
     movie_info_idx AS mi_idx,
     movie_link AS ml,
     title AS t1,
     title AS t
WHERE cn1.country_code = '[us]'
  AND it1.info = 'rating'
  AND it.info = 'rating'
  AND kt1.kind IN ('tv series')
  AND kt.kind IN ('tv series')
  AND lt.link IN ('sequel',
                  'follows',
                  'followed by')
  AND mi_idx.info < '3.0'
  AND t.production_year BETWEEN 2005 AND 2008
  AND lt.id = ml.link_type_id
  AND t1.id = ml.movie_id
  AND t.id = ml.linked_movie_id
  AND it1.id = mi_idx1.info_type_id
  AND t1.id = mi_idx1.movie_id
  AND kt1.id = t1.kind_id
  AND cn1.id = mc1.company_id
  AND t1.id = mc1.movie_id
  AND ml.movie_id = mi_idx1.movie_id
  AND ml.movie_id = mc1.movie_id
  AND mi_idx1.movie_id = mc1.movie_id
  AND it.id = mi_idx.info_type_id
  AND t.id = mi_idx.movie_id
  AND kt.id = t.kind_id
  AND cn.id = mc.company_id
  AND t.id = mc.movie_id
  AND ml.linked_movie_id = mi_idx.movie_id
  AND ml.linked_movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id;



Aggregate  (cost=4539.57..4539.58 rows=1 width=192)
  ->  Nested Loop  (cost=1875.80..4539.56 rows=1 width=82)
        Join Filter: ((t.id = mi_idx.movie_id) AND (it.id = mi_idx.info_type_id))
        ->  Gather  (cost=1875.37..4539.02 rows=1 width=93)
              Workers Planned: 2
              ->  Nested Loop  (cost=875.37..3538.92 rows=1 width=93)
                    ->  Nested Loop  (cost=875.24..3538.60 rows=2 width=97)
                          Join Filter: (ml.movie_id = t1.id)
                          ->  Nested Loop  (cost=874.81..3537.55 rows=2 width=88)
                                ->  Nested Loop  (cost=874.39..3536.66 rows=2 width=73)
                                      ->  Hash Join  (cost=873.96..3535.05 rows=2 width=65)
                                            Hash Cond: (t.kind_id = kt.id)
                                            ->  Nested Loop  (cost=872.86..3533.87 rows=18 width=69)
                                                  ->  Nested Loop  (cost=872.43..3084.38 rows=107 width=44)
                                                        ->  Nested Loop  (cost=872.43..2825.17 rows=107 width=40)
                                                              ->  Nested Loop  (cost=872.01..2694.61 rows=293 width=25)
                                                                    Join Filter: (ml.movie_id = mc1.movie_id)
                                                                    ->  Hash Join  (cost=871.58..2655.95 rows=59 width=17)
                                                                          Hash Cond: (mi_idx1.info_type_id = it1.id)
                                                                          ->  Merge Join  (cost=869.15..2635.31 rows=6690 width=21)
                                                                                Merge Cond: (mi_idx1.movie_id = ml.movie_id)
                                                                                ->  Parallel Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx1  (cost=0.43..35764.44 rows=575015 width=13)
                                                                                ->  Sort  (cost=868.72..881.22 rows=5000 width=8)
                                                                                      Sort Key: ml.movie_id
                                                                                      ->  Hash Join  (cost=1.29..561.53 rows=5000 width=8)
                                                                                            Hash Cond: (ml.link_type_id = lt.id)
                                                                                            ->  Seq Scan on movie_link ml  (cost=0.00..462.97 rows=29997 width=12)
                                                                                            ->  Hash  (cost=1.25..1.25 rows=3 width=4)
                                                                                                  ->  Seq Scan on link_type lt  (cost=0.00..1.25 rows=3 width=4)
                                                                                                        Filter: ((link)::text = ANY ('{sequel,follows,"followed by"}'::text[]))
                                                                          ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                                                ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                                                      Filter: ((info)::text = 'rating'::text)
                                                                    ->  Index Scan using movie_id_movie_companies on movie_companies mc1  (cost=0.43..0.59 rows=5 width=8)
                                                                          Index Cond: (movie_id = mi_idx1.movie_id)
                                                              ->  Index Scan using company_name_pkey on company_name cn1  (cost=0.42..0.45 rows=1 width=23)
                                                                    Index Cond: (id = mc1.company_id)
                                                                    Filter: ((country_code)::text = '[us]'::text)
                                                        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                              Filter: ((info)::text = 'rating'::text)
                                                  ->  Index Scan using title_pkey on title t  (cost=0.43..4.20 rows=1 width=25)
                                                        Index Cond: (id = ml.linked_movie_id)
                                                        Filter: ((production_year >= 2005) AND (production_year <= 2008))
                                            ->  Hash  (cost=1.09..1.09 rows=1 width=4)
                                                  ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                                        Filter: ((kind)::text = 'tv series'::text)
                                      ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.75 rows=5 width=8)
                                            Index Cond: (movie_id = t.id)
                                ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.44 rows=1 width=23)
                                      Index Cond: (id = mc.company_id)
                          ->  Index Scan using title_pkey on title t1  (cost=0.43..0.51 rows=1 width=25)
                                Index Cond: (id = mc1.movie_id)
                    ->  Index Scan using kind_type_pkey on kind_type kt1  (cost=0.13..0.15 rows=1 width=4)
                          Index Cond: (id = t1.kind_id)
                          Filter: ((kind)::text = 'tv series'::text)
        ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.51 rows=2 width=13)
              Index Cond: (movie_id = mc.movie_id)
              Filter: ((info)::text < '3.0'::text)
