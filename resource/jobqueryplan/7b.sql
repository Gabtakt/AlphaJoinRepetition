SELECT MIN(n.name) AS of_person,
       MIN(t.title) AS biography_movie
FROM aka_name AS an,
     cast_info AS ci,
     info_type AS it,
     link_type AS lt,
     movie_link AS ml,
     name AS n,
     person_info AS pi,
     title AS t
WHERE an.name LIKE '%a%'
  AND it.info = 'mini biography'
  AND lt.link = 'features'
  AND n.name_pcode_cf LIKE 'D%'
  AND n.gender = 'm'
  AND pi.note = 'Volker Boehm'
  AND t.production_year BETWEEN 1980 AND 1984
  AND n.id = an.person_id
  AND n.id = pi.person_id
  AND ci.person_id = n.id
  AND t.id = ci.movie_id
  AND ml.linked_movie_id = t.id
  AND lt.id = ml.link_type_id
  AND it.id = pi.info_type_id
  AND pi.person_id = an.person_id
  AND pi.person_id = ci.person_id
  AND an.person_id = ci.person_id
  AND ci.movie_id = ml.linked_movie_id;



Aggregate  (cost=9080.48..9080.49 rows=1 width=64)
  ->  Nested Loop  (cost=41.24..9080.48 rows=1 width=32)
        ->  Nested Loop  (cost=41.10..9079.37 rows=1 width=36)
              Join Filter: (n.id = an.person_id)
              ->  Nested Loop  (cost=40.67..9078.88 rows=1 width=48)
                    Join Filter: (n.id = pi.person_id)
                    ->  Nested Loop  (cost=40.24..9036.15 rows=46 width=40)
                          ->  Nested Loop  (cost=39.81..8143.02 rows=1942 width=21)
                                ->  Nested Loop  (cost=39.25..7243.89 rows=51 width=25)
                                      ->  Nested Loop  (cost=38.82..245.23 rows=1666 width=4)
                                            ->  Seq Scan on link_type lt  (cost=0.00..1.23 rows=1 width=4)
                                                  Filter: ((link)::text = 'features'::text)
                                            ->  Bitmap Heap Scan on movie_link ml  (cost=38.82..225.26 rows=1875 width=8)
                                                  Recheck Cond: (link_type_id = lt.id)
                                                  ->  Bitmap Index Scan on link_type_id_movie_link  (cost=0.00..38.35 rows=1875 width=0)
                                                        Index Cond: (link_type_id = lt.id)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..4.20 rows=1 width=21)
                                            Index Cond: (id = ml.linked_movie_id)
                                            Filter: ((production_year >= 1980) AND (production_year <= 1984))
                                ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..17.25 rows=38 width=8)
                                      Index Cond: (movie_id = t.id)
                          ->  Index Scan using name_pkey on name n  (cost=0.43..0.46 rows=1 width=19)
                                Index Cond: (id = ci.person_id)
                                Filter: (((name_pcode_cf)::text ~~ 'D%'::text) AND ((gender)::text = 'm'::text))
                    ->  Index Scan using person_id_person_info on person_info pi  (cost=0.43..0.92 rows=1 width=8)
                          Index Cond: (person_id = ci.person_id)
                          Filter: ((note)::text = 'Volker Boehm'::text)
              ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..0.47 rows=2 width=4)
                    Index Cond: (person_id = ci.person_id)
                    Filter: ((name)::text ~~ '%a%'::text)
        ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.62 rows=1 width=4)
              Index Cond: (id = pi.info_type_id)
              Filter: ((info)::text = 'mini biography'::text)
