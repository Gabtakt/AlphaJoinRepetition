SELECT MIN(kt.kind) AS movie_kind,
       MIN(t.title) AS complete_us_internet_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     keyword AS k,
     kind_type AS kt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     title AS t
WHERE cct1.kind = 'complete+verified'
  AND cn.country_code = '[us]'
  AND it1.info = 'release dates'
  AND kt.kind IN ('movie')
  AND mi.note LIKE '%internet%'
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'USA:% 199%'
       OR mi.info LIKE 'USA:% 200%')
  AND t.production_year > 2000
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mc.movie_id
  AND t.id = cc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = cc.movie_id
  AND mc.movie_id = cc.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND cct1.id = cc.status_id;



Aggregate  (cost=57955.12..57955.13 rows=1 width=64)
  ->  Nested Loop  (cost=4238.90..57955.11 rows=1 width=27)
        ->  Nested Loop  (cost=4238.48..57954.67 rows=1 width=31)
              ->  Nested Loop  (cost=4238.35..57954.52 rows=1 width=35)
                    ->  Nested Loop  (cost=4237.93..57954.07 rows=1 width=39)
                          Join Filter: (t.id = mc.movie_id)
                          ->  Nested Loop  (cost=4237.50..57953.47 rows=1 width=47)
                                ->  Gather  (cost=4237.06..57951.69 rows=1 width=39)
                                      Workers Planned: 2
                                      ->  Nested Loop  (cost=3237.06..56951.59 rows=1 width=39)
                                            ->  Nested Loop  (cost=3236.92..56951.33 rows=1 width=43)
                                                  ->  Hash Join  (cost=3236.49..54651.40 rows=1089 width=35)
                                                        Hash Cond: (t.kind_id = kt.id)
                                                        ->  Hash Join  (cost=3235.39..54618.17 rows=7624 width=29)
                                                              Hash Cond: (t.id = cc.movie_id)
                                                              ->  Parallel Seq Scan on title t  (cost=0.00..49166.29 rows=570735 width=25)
                                                                    Filter: (production_year > 2000)
                                                              ->  Hash  (cost=2813.24..2813.24 rows=33772 width=4)
                                                                    ->  Hash Join  (cost=1.06..2813.24 rows=33772 width=4)
                                                                          Hash Cond: (cc.status_id = cct1.id)
                                                                          ->  Seq Scan on complete_cast cc  (cost=0.00..2081.86 rows=135086 width=8)
                                                                          ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                                                                ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                                                                      Filter: ((kind)::text = 'complete+verified'::text)
                                                        ->  Hash  (cost=1.09..1.09 rows=1 width=14)
                                                              ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=14)
                                                                    Filter: ((kind)::text = 'movie'::text)
                                                  ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..2.10 rows=1 width=8)
                                                        Index Cond: (movie_id = t.id)
                                                        Filter: ((info IS NOT NULL) AND ((note)::text ~~ '%internet%'::text) AND (((info)::text ~~ 'USA:% 199%'::text) OR ((info)::text ~~ 'USA:% 200%'::text)))
                                            ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.20 rows=1 width=4)
                                                  Index Cond: (id = mi.info_type_id)
                                                  Filter: ((info)::text = 'release dates'::text)
                                ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.33 rows=45 width=8)
                                      Index Cond: (movie_id = t.id)
                          ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=5 width=12)
                                Index Cond: (movie_id = mk.movie_id)
                    ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                          Index Cond: (id = mc.company_id)
                          Filter: ((country_code)::text = '[us]'::text)
              ->  Index Only Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                    Index Cond: (id = mc.company_type_id)
        ->  Index Only Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
              Index Cond: (id = mk.keyword_id)
