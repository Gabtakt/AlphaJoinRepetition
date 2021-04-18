SELECT MIN(cn.name) AS movie_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS drama_horror_movie
FROM company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     title AS t
WHERE cn.country_code = '[us]'
  AND ct.kind = 'production companies'
  AND it1.info = 'genres'
  AND it.info = 'rating'
  AND mi.info IN ('Drama',
                  'Horror')
  AND mi_idx.info > '8.0'
  AND t.production_year BETWEEN 2005 AND 2008
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND mi.info_type_id = it1.id
  AND mi_idx.info_type_id = it.id
  AND t.id = mc.movie_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id;


Aggregate  (cost=16826.54..16826.55 rows=1 width=96)
  ->  Gather  (cost=1005.35..16826.53 rows=1 width=41)
        Workers Planned: 2
        ->  Nested Loop  (cost=5.34..15826.43 rows=1 width=41)
              ->  Nested Loop  (cost=5.20..15824.78 rows=10 width=45)
                    Join Filter: (t.id = mi.movie_id)
                    ->  Nested Loop  (cost=4.77..15802.13 rows=14 width=53)
                          ->  Nested Loop  (cost=4.35..15785.19 rows=38 width=38)
                                Join Filter: (mi_idx.movie_id = t.id)
                                ->  Hash Join  (cost=3.92..15668.94 rows=219 width=17)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Nested Loop  (cost=2.86..15663.15 rows=876 width=21)
                                            ->  Hash Join  (cost=2.43..15179.52 rows=177 width=9)
                                                  Hash Cond: (mi_idx.info_type_id = it.id)
                                                  ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..15122.68 rows=19980 width=13)
                                                        Filter: ((info)::text > '8.0'::text)
                                                  ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                              Filter: ((info)::text = 'rating'::text)
                                            ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.68 rows=5 width=12)
                                                  Index Cond: (movie_id = mi_idx.movie_id)
                                      ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.52 rows=1 width=21)
                                      Index Cond: (id = mc.movie_id)
                                      Filter: ((production_year >= 2005) AND (production_year <= 2008))
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=23)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.61 rows=1 width=8)
                          Index Cond: (movie_id = mc.movie_id)
                          Filter: ((info)::text = ANY ('{Drama,Horror}'::text[]))
              ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                    Index Cond: (id = mi.info_type_id)
                    Filter: ((info)::text = 'genres'::text)
