SELECT MIN(cn.name) AS producing_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS movie
FROM company_name AS cn,
     company_type AS ct,
     info_type AS it,
     info_type AS it1,
     kind_type AS kt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     title AS t
WHERE cn.country_code = '[us]'
  AND ct.kind = 'production companies'
  AND it.info = 'rating'
  AND it1.info = 'release dates'
  AND kt.kind = 'movie'
  AND mi.movie_id = t.id
  AND it1.id = mi.info_type_id
  AND kt.id = t.kind_id
  AND mc.movie_id = t.id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND mi_idx.movie_id = t.id
  AND it.id = mi_idx.info_type_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id;



Finalize Aggregate  (cost=20721.17..20721.18 rows=1 width=96)
  ->  Gather  (cost=20720.94..20721.15 rows=2 width=96)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=19720.94..19720.95 rows=1 width=96)
              ->  Hash Join  (cost=8.73..19720.19 rows=100 width=41)
                    Hash Cond: (mi.info_type_id = it1.id)
                    ->  Nested Loop  (cost=6.30..19686.94 rows=11320 width=45)
                          ->  Nested Loop  (cost=5.87..19051.21 rows=328 width=53)
                                ->  Hash Join  (cost=5.45..18649.74 rows=901 width=38)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Nested Loop  (cost=4.39..18629.17 rows=3606 width=42)
                                            ->  Hash Join  (cost=3.96..18186.75 rows=727 width=30)
                                                  Hash Cond: (t.kind_id = kt.id)
                                                  ->  Nested Loop  (cost=2.86..18164.20 rows=5089 width=34)
                                                        ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=9)
                                                              Hash Cond: (mi_idx.info_type_id = it.id)
                                                              ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=13)
                                                              ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                                    ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                                          Filter: ((info)::text = 'rating'::text)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..0.57 rows=1 width=25)
                                                              Index Cond: (id = mi_idx.movie_id)
                                                  ->  Hash  (cost=1.09..1.09 rows=1 width=4)
                                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                                              Filter: ((kind)::text = 'movie'::text)
                                            ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.56 rows=5 width=12)
                                                  Index Cond: (movie_id = t.id)
                                      ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=23)
                                      Index Cond: (id = mc.company_id)
                                      Filter: ((country_code)::text = '[us]'::text)
                          ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.51 rows=43 width=8)
                                Index Cond: (movie_id = t.id)
                    ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                          ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                Filter: ((info)::text = 'release dates'::text)
