SELECT MIN(cn.name) AS movie_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS western_violent_movie
FROM company_name AS cn,
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
WHERE cn.country_code != '[us]'
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
  AND mi.info IN ('Germany',
                  'German',
                  'USA',
                  'American')
  AND mi_idx.info < '7.0'
  AND t.production_year > 2008
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = mc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mk.movie_id = mc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id;



Aggregate  (cost=7443.49..7443.50 rows=1 width=96)
  ->  Nested Loop  (cost=8.92..7443.48 rows=1 width=41)
        Join Filter: (mi.info_type_id = it1.id)
        ->  Nested Loop  (cost=8.92..7441.06 rows=1 width=45)
              Join Filter: (t.id = mi.movie_id)
              ->  Nested Loop  (cost=8.49..7439.45 rows=1 width=57)
                    Join Filter: (mc.company_type_id = ct.id)
                    ->  Nested Loop  (cost=8.49..7438.36 rows=1 width=61)
                          ->  Nested Loop  (cost=8.07..7437.81 rows=1 width=46)
                                Join Filter: (t.id = mc.movie_id)
                                ->  Nested Loop  (cost=7.64..7437.24 rows=1 width=34)
                                      Join Filter: (mi_idx.info_type_id = it.id)
                                      ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                            Filter: ((info)::text = 'rating'::text)
                                      ->  Nested Loop  (cost=7.64..7434.47 rows=28 width=38)
                                            Join Filter: (t.id = mi_idx.movie_id)
                                            ->  Nested Loop  (cost=7.21..7429.12 rows=10 width=25)
                                                  Join Filter: (t.kind_id = kt.id)
                                                  ->  Nested Loop  (cost=7.21..7427.03 rows=35 width=29)
                                                        ->  Nested Loop  (cost=6.78..7361.15 rows=135 width=4)
                                                              ->  Seq Scan on keyword k  (cost=0.00..2961.55 rows=4 width=4)
                                                                    Filter: ((keyword)::text = ANY ('{murder,murder-in-title,blood,violence}'::text[]))
                                                              ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1096.87 rows=303 width=8)
                                                                    Recheck Cond: (keyword_id = k.id)
                                                                    ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                          Index Cond: (keyword_id = k.id)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                                              Index Cond: (id = mk.movie_id)
                                                              Filter: (production_year > 2008)
                                                  ->  Materialize  (cost=0.00..1.10 rows=2 width=4)
                                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=2 width=4)
                                                              Filter: ((kind)::text = ANY ('{movie,episode}'::text[]))
                                            ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.50 rows=3 width=13)
                                                  Index Cond: (movie_id = mk.movie_id)
                                                  Filter: ((info)::text < '7.0'::text)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.57 rows=1 width=12)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: (((note)::text !~~ '%(USA)%'::text) AND ((note)::text ~~ '%(200%)%'::text))
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.55 rows=1 width=23)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text <> '[us]'::text)
                    ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.58 rows=2 width=8)
                    Index Cond: (movie_id = mk.movie_id)
                    Filter: ((info)::text = ANY ('{Germany,German,USA,American}'::text[]))
        ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
              Filter: ((info)::text = 'countries'::text)
