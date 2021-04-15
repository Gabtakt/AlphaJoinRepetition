SELECT MIN(kt.kind) AS movie_kind,
       MIN(t.title) AS complete_nerdy_internet_movie
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
  AND k.keyword IN ('nerd',
                    'loner',
                    'alienation',
                    'dignity')
  AND kt.kind IN ('movie')
  AND mi.note LIKE '%internet%'
  AND mi.info LIKE 'USA:% 200%'
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



Aggregate  (cost=7443.29..7443.30 rows=1 width=64)
  ->  Nested Loop  (cost=8.92..7443.29 rows=1 width=27)
        Join Filter: (mi.info_type_id = it1.id)
        ->  Nested Loop  (cost=8.92..7440.86 rows=1 width=31)
              Join Filter: (t.id = mi.movie_id)
              ->  Nested Loop  (cost=8.48..7439.27 rows=1 width=43)
                    Join Filter: (mc.company_type_id = ct.id)
                    ->  Nested Loop  (cost=8.48..7438.18 rows=1 width=47)
                          ->  Nested Loop  (cost=8.06..7436.84 rows=3 width=51)
                                Join Filter: (t.id = mc.movie_id)
                                ->  Nested Loop  (cost=7.63..7435.03 rows=3 width=39)
                                      Join Filter: (cc.status_id = cct1.id)
                                      ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                            Filter: ((kind)::text = 'complete+verified'::text)
                                      ->  Nested Loop  (cost=7.63..7433.81 rows=14 width=43)
                                            ->  Nested Loop  (cost=7.21..7429.03 rows=10 width=35)
                                                  Join Filter: (t.kind_id = kt.id)
                                                  ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=14)
                                                        Filter: ((kind)::text = 'movie'::text)
                                                  ->  Nested Loop  (cost=7.21..7427.03 rows=73 width=29)
                                                        ->  Nested Loop  (cost=6.78..7361.15 rows=135 width=4)
                                                              ->  Seq Scan on keyword k  (cost=0.00..2961.55 rows=4 width=4)
                                                                    Filter: ((keyword)::text = ANY ('{nerd,loner,alienation,dignity}'::text[]))
                                                              ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1096.87 rows=303 width=8)
                                                                    Recheck Cond: (keyword_id = k.id)
                                                                    ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                          Index Cond: (keyword_id = k.id)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                                              Index Cond: (id = mk.movie_id)
                                                              Filter: (production_year > 2000)
                                            ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=8)
                                                  Index Cond: (movie_id = t.id)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=5 width=12)
                                      Index Cond: (movie_id = mk.movie_id)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.58 rows=1 width=8)
                    Index Cond: (movie_id = mk.movie_id)
                    Filter: (((note)::text ~~ '%internet%'::text) AND ((info)::text ~~ 'USA:% 200%'::text))
        ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
              Filter: ((info)::text = 'release dates'::text)
