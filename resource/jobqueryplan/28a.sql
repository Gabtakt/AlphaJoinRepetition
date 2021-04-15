SELECT MIN(cn.name) AS movie_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS complete_euro_dark_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     info_type AS it,
     keyword AS k,
     kind_type AS kt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     title AS t
WHERE cct1.kind = 'crew'
  AND cct2.kind != 'complete+verified'
  AND cn.country_code != '[us]'
  AND it1.info = 'countries'
  AND it.info = 'rating'
  AND k.keyword IN ('murder',
                    'murder-in-title',
                    'blood',
                    'violence')
  AND kt.kind IN ('movie',
                  'episode')
  AND mc.note NOT LIKE '%(USA)%'
  AND mc.note LIKE '%(200%)%'
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Danish',
                  'Norwegian',
                  'German',
                  'USA',
                  'American')
  AND mi_idx.info < '8.5'
  AND t.production_year > 2000
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = mc.movie_id
  AND t.id = cc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = cc.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi_idx.movie_id = cc.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;



Aggregate  (cost=7452.41..7452.42 rows=1 width=96)
  ->  Nested Loop  (cost=9.34..7452.40 rows=1 width=41)
        Join Filter: (ct.id = mc.company_type_id)
        ->  Nested Loop  (cost=9.34..7451.31 rows=1 width=45)
              ->  Nested Loop  (cost=8.92..7450.77 rows=1 width=30)
                    Join Filter: (t.id = mc.movie_id)
                    ->  Nested Loop  (cost=8.49..7450.19 rows=1 width=42)
                          Join Filter: (cc.subject_id = cct1.id)
                          ->  Nested Loop  (cost=8.49..7449.13 rows=1 width=46)
                                Join Filter: (cct2.id = cc.status_id)
                                ->  Nested Loop  (cost=8.49..7448.04 rows=1 width=50)
                                      ->  Nested Loop  (cost=8.07..7447.56 rows=1 width=38)
                                            Join Filter: (it1.id = mi.info_type_id)
                                            ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'countries'::text)
                                            ->  Nested Loop  (cost=8.07..7445.14 rows=1 width=42)
                                                  Join Filter: (t.id = mi.movie_id)
                                                  ->  Nested Loop  (cost=7.64..7443.21 rows=1 width=34)
                                                        Join Filter: (kt.id = t.kind_id)
                                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=2 width=4)
                                                              Filter: ((kind)::text = ANY ('{movie,episode}'::text[]))
                                                        ->  Materialize  (cost=7.64..7442.06 rows=2 width=38)
                                                              ->  Nested Loop  (cost=7.64..7442.05 rows=2 width=38)
                                                                    ->  Nested Loop  (cost=7.21..7440.10 rows=4 width=13)
                                                                          Join Filter: (it.id = mi_idx.info_type_id)
                                                                          ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                                                Filter: ((info)::text = 'rating'::text)
                                                                          ->  Nested Loop  (cost=7.21..7432.41 rows=422 width=17)
                                                                                ->  Nested Loop  (cost=6.78..7361.15 rows=135 width=4)
                                                                                      ->  Seq Scan on keyword k  (cost=0.00..2961.55 rows=4 width=4)
                                                                                            Filter: ((keyword)::text = ANY ('{murder,murder-in-title,blood,violence}'::text[]))
                                                                                      ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1096.87 rows=303 width=8)
                                                                                            Recheck Cond: (keyword_id = k.id)
                                                                                            ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                                  Index Cond: (keyword_id = k.id)
                                                                                ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.50 rows=3 width=13)
                                                                                      Index Cond: (movie_id = mk.movie_id)
                                                                                      Filter: ((info)::text < '8.5'::text)
                                                                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                                                          Index Cond: (id = mk.movie_id)
                                                                          Filter: (production_year > 2000)
                                                  ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.90 rows=2 width=8)
                                                        Index Cond: (movie_id = mk.movie_id)
                                                        Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Danish,Norwegian,German,USA,American}'::text[]))
                                      ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=12)
                                            Index Cond: (movie_id = t.id)
                                ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=3 width=4)
                                      Filter: ((kind)::text <> 'complete+verified'::text)
                          ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                Filter: ((kind)::text = 'crew'::text)
                    ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.57 rows=1 width=12)
                          Index Cond: (movie_id = mk.movie_id)
                          Filter: (((note)::text !~~ '%(USA)%'::text) AND ((note)::text ~~ '%(200%)%'::text))
              ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.55 rows=1 width=23)
                    Index Cond: (id = mc.company_id)
                    Filter: ((country_code)::text <> '[us]'::text)
        ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
