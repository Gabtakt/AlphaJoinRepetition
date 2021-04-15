SELECT MIN(chn.name) AS voiced_char_name,
       MIN(n.name) AS voicing_actress_name,
       MIN(t.title) AS kung_fu_panda
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     info_type AS it,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND cn.name = 'DreamWorks Animation'
  AND it.info = 'release dates'
  AND k.keyword IN ('hero',
                    'martial-arts',
                    'hand-to-hand-combat',
                    'computer-animated-movie')
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%201%'
       OR mi.info LIKE 'USA:%201%')
  AND n.gender = 'f'
  AND n.name LIKE '%An%'
  AND rt.role = 'actress'
  AND t.production_year > 2010
  AND t.title LIKE 'Kung Fu Panda%'
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND mc.movie_id = ci.movie_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mk.movie_id
  AND mi.movie_id = ci.movie_id
  AND mi.movie_id = mk.movie_id
  AND ci.movie_id = mk.movie_id
  AND cn.id = mc.company_id
  AND it.id = mi.info_type_id
  AND n.id = ci.person_id
  AND rt.id = ci.role_id
  AND n.id = an.person_id
  AND ci.person_id = an.person_id
  AND chn.id = ci.person_role_id
  AND k.id = mk.keyword_id;



Aggregate  (cost=6520.92..6520.93 rows=1 width=96)
  ->  Nested Loop  (cost=1004.27..6520.91 rows=1 width=48)
        ->  Nested Loop  (cost=1004.13..6520.73 rows=1 width=52)
              Join Filter: (t.id = mi.movie_id)
              ->  Nested Loop  (cost=1003.70..6487.34 rows=1 width=64)
                    Join Filter: (n.id = an.person_id)
                    ->  Nested Loop  (cost=1003.27..6485.23 rows=1 width=72)
                          ->  Nested Loop  (cost=1003.14..6485.06 rows=1 width=76)
                                ->  Nested Loop  (cost=1002.71..6483.25 rows=1 width=57)
                                      ->  Nested Loop  (cost=1002.28..6481.54 rows=1 width=45)
                                            Join Filter: (t.id = ci.movie_id)
                                            ->  Gather  (cost=1001.71..6440.67 rows=1 width=29)
                                                  Workers Planned: 1
                                                  ->  Nested Loop  (cost=1.71..5440.57 rows=1 width=29)
                                                        ->  Nested Loop  (cost=1.29..5438.69 rows=1 width=33)
                                                              Join Filter: (t.id = mk.movie_id)
                                                              ->  Nested Loop  (cost=0.86..5435.68 rows=1 width=25)
                                                                    ->  Nested Loop  (cost=0.43..5426.02 rows=6 width=4)
                                                                          ->  Parallel Seq Scan on company_name cn  (cost=0.00..5068.50 rows=1 width=4)
                                                                                Filter: (((country_code)::text = '[us]'::text) AND ((name)::text = 'DreamWorks Animation'::text))
                                                                          ->  Index Scan using company_id_movie_companies on movie_companies mc  (cost=0.43..356.19 rows=133 width=8)
                                                                                Index Cond: (company_id = cn.id)
                                                                    ->  Index Scan using title_pkey on title t  (cost=0.43..1.60 rows=1 width=21)
                                                                          Index Cond: (id = mc.movie_id)
                                                                          Filter: ((production_year > 2010) AND ((title)::text ~~ 'Kung Fu Panda%'::text))
                                                              ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..2.45 rows=45 width=8)
                                                                    Index Cond: (movie_id = mc.movie_id)
                                                        ->  Index Scan using keyword_pkey on keyword k  (cost=0.42..1.46 rows=1 width=4)
                                                              Index Cond: (id = mk.keyword_id)
                                                              Filter: ((keyword)::text = ANY ('{hero,martial-arts,hand-to-hand-combat,computer-animated-movie}'::text[]))
                                            ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..40.85 rows=1 width=16)
                                                  Index Cond: (movie_id = mk.movie_id)
                                                  Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                      ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..1.71 rows=1 width=20)
                                            Index Cond: (id = ci.person_role_id)
                                ->  Index Scan using name_pkey on name n  (cost=0.43..1.81 rows=1 width=19)
                                      Index Cond: (id = ci.person_id)
                                      Filter: (((name)::text ~~ '%An%'::text) AND ((gender)::text = 'f'::text))
                          ->  Index Scan using role_type_pkey on role_type rt  (cost=0.14..0.16 rows=1 width=4)
                                Index Cond: (id = ci.role_id)
                                Filter: ((role)::text = 'actress'::text)
                    ->  Index Only Scan using person_id_aka_name on aka_name an  (cost=0.42..2.08 rows=2 width=4)
                          Index Cond: (person_id = ci.person_id)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..33.38 rows=1 width=8)
                    Index Cond: (movie_id = mk.movie_id)
                    Filter: ((info IS NOT NULL) AND (((info)::text ~~ 'Japan:%201%'::text) OR ((info)::text ~~ 'USA:%201%'::text)))
        ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
              Index Cond: (id = mi.info_type_id)
              Filter: ((info)::text = 'release dates'::text)
