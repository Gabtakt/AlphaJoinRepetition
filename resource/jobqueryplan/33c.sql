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
WHERE cn1.country_code != '[us]'
  AND it1.info = 'rating'
  AND it.info = 'rating'
  AND kt1.kind IN ('tv series',
                   'episode')
  AND kt.kind IN ('tv series',
                   'episode')
  AND lt.link IN ('sequel',
                  'follows',
                  'followed by')
  AND mi_idx.info < '3.5'
  AND t.production_year BETWEEN 2000 AND 2010
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



Aggregate  (cost=4457.79..4457.80 rows=1 width=192)
  ->  Nested Loop  (cost=3.74..4457.77 rows=1 width=82)
        ->  Nested Loop  (cost=3.32..4457.33 rows=1 width=67)
              ->  Nested Loop  (cost=2.89..4456.66 rows=1 width=75)
                    ->  Nested Loop  (cost=2.47..4456.21 rows=1 width=60)
                          ->  Nested Loop  (cost=2.04..4455.61 rows=1 width=68)
                                Join Filter: (mi_idx.info_type_id = it.id)
                                ->  Nested Loop  (cost=2.04..4453.07 rows=8 width=72)
                                      Join Filter: (kt1.id = t1.kind_id)
                                      ->  Nested Loop  (cost=2.04..4451.21 rows=27 width=76)
                                            Join Filter: (ml.movie_id = t1.id)
                                            ->  Nested Loop  (cost=1.61..4435.43 rows=27 width=51)
                                                  Join Filter: (t.kind_id = kt.id)
                                                  ->  Nested Loop  (cost=1.61..4431.65 rows=94 width=55)
                                                        Join Filter: (ml.linked_movie_id = t.id)
                                                        ->  Nested Loop  (cost=1.18..4267.03 rows=232 width=30)
                                                              ->  Nested Loop  (cost=0.75..3972.97 rows=142 width=17)
                                                                    Join Filter: (ml.link_type_id = lt.id)
                                                                    ->  Merge Join  (cost=0.75..3934.44 rows=852 width=21)
                                                                          Merge Cond: (mi_idx1.movie_id = ml.movie_id)
                                                                          ->  Nested Loop  (cost=0.43..64517.59 rows=12213 width=9)
                                                                                Join Filter: (it1.id = mi_idx1.info_type_id)
                                                                                ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx1  (cost=0.43..43814.65 rows=1380035 width=13)
                                                                                ->  Materialize  (cost=0.00..2.42 rows=1 width=4)
                                                                                      ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                                                            Filter: ((info)::text = 'rating'::text)
                                                                          ->  Index Scan using movie_id_movie_link on movie_link ml  (cost=0.29..959.51 rows=29997 width=12)
                                                                    ->  Materialize  (cost=0.00..1.26 rows=3 width=4)
                                                                          ->  Seq Scan on link_type lt  (cost=0.00..1.25 rows=3 width=4)
                                                                                Filter: ((link)::text = ANY ('{sequel,follows,"followed by"}'::text[]))
                                                              ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..2.05 rows=2 width=13)
                                                                    Index Cond: (movie_id = ml.linked_movie_id)
                                                                    Filter: ((info)::text < '3.5'::text)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..0.70 rows=1 width=25)
                                                              Index Cond: (id = mi_idx.movie_id)
                                                              Filter: ((production_year >= 2000) AND (production_year <= 2010))
                                                  ->  Materialize  (cost=0.00..1.10 rows=2 width=4)
                                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=2 width=4)
                                                              Filter: ((kind)::text = ANY ('{"tv series",episode}'::text[]))
                                            ->  Index Scan using title_pkey on title t1  (cost=0.43..0.57 rows=1 width=25)
                                                  Index Cond: (id = mi_idx1.movie_id)
                                      ->  Materialize  (cost=0.00..1.10 rows=2 width=4)
                                            ->  Seq Scan on kind_type kt1  (cost=0.00..1.09 rows=2 width=4)
                                                  Filter: ((kind)::text = ANY ('{"tv series",episode}'::text[]))
                                ->  Materialize  (cost=0.00..2.42 rows=1 width=4)
                                      ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                            Filter: ((info)::text = 'rating'::text)
                          ->  Index Scan using movie_id_movie_companies on movie_companies mc1  (cost=0.43..0.56 rows=5 width=8)
                                Index Cond: (movie_id = t1.id)
                    ->  Index Scan using company_name_pkey on company_name cn1  (cost=0.42..0.45 rows=1 width=23)
                          Index Cond: (id = mc1.company_id)
                          Filter: ((country_code)::text <> '[us]'::text)
              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.62 rows=5 width=8)
                    Index Cond: (movie_id = t.id)
        ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.44 rows=1 width=23)
              Index Cond: (id = mc.company_id)
