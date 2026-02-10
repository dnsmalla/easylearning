#!/usr/bin/env python3
"""
Build worldwide Nepali/Indian restaurant dataset from OpenStreetMap (Overpass).

Usage examples:
  python3 build_osm.py --country "Japan" --out ../data/restaurants_global.json
  python3 build_osm.py --bbox "34.0,135.0,36.0,140.0" --out ../data/restaurants_global.json
  python3 build_osm.py --country "United States" --country "United Kingdom" --out ../data/restaurants_global.json
"""

import argparse
import datetime as dt
import json
import re
import sys
import urllib.parse
import urllib.request
from typing import Optional, Tuple

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

CUISINE_MAP = [
    ("nepali", "Nepali"),
    ("indian", "Indian"),
    ("north_indian", "North Indian"),
    ("south_indian", "South Indian"),
    ("indo-nepali", "Indo-Nepali"),
    ("himalayan", "Himalayan"),
]

DEFAULT_COVER = "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe"


def normalize_cuisine(tag_value: str) -> Optional[str]:
    if not tag_value:
        return None
    value = tag_value.lower().replace(" ", "_")
    parts = re.split(r"[;,]", value)
    parts = [p.strip() for p in parts if p.strip()]
    for key, mapped in CUISINE_MAP:
        if key in parts:
            return mapped
    return None


def build_address(tags: dict) -> str:
    addr_full = tags.get("addr:full")
    if addr_full:
        return addr_full
    parts = [
        tags.get("addr:housenumber"),
        tags.get("addr:street"),
        tags.get("addr:suburb"),
        tags.get("addr:city"),
        tags.get("addr:state"),
        tags.get("addr:postcode"),
        tags.get("addr:country"),
    ]
    return ", ".join([p for p in parts if p])


def guess_city(tags: dict) -> Optional[str]:
    return (
        tags.get("addr:city")
        or tags.get("addr:town")
        or tags.get("addr:village")
        or tags.get("addr:suburb")
        or tags.get("addr:hamlet")
    )


def guess_country(tags: dict) -> Optional[str]:
    return tags.get("addr:country") or tags.get("country")


def overpass_query(countries: list[str], bboxes: list[str]) -> str:
    filters = '["amenity"="restaurant"]["cuisine"~"indian|nepali",i]'
    queries = []

    for country in countries:
        queries.append(
            f'area["name"="{country}"]["boundary"="administrative"]["admin_level"="2"]->.a;'
            f'(node{filters}(area.a);way{filters}(area.a);relation{filters}(area.a););'
        )

    for bbox in bboxes:
        queries.append(f"(node{filters}({bbox});way{filters}({bbox});relation{filters}({bbox}););")

    if not queries:
        raise ValueError("Provide at least one --country or --bbox.")

    query_body = "(".join([""] + queries) + ")"
    return f"[out:json][timeout:180];{query_body}out center tags;"


def fetch_overpass(query: str) -> dict:
    data = urllib.parse.urlencode({"data": query}).encode("utf-8")
    req = urllib.request.Request(OVERPASS_URL, data=data, method="POST")
    with urllib.request.urlopen(req, timeout=240) as resp:
        return json.loads(resp.read().decode("utf-8"))


def element_center(el: dict) -> Tuple[Optional[float], Optional[float]]:
    if el.get("type") == "node":
        return el.get("lat"), el.get("lon")
    center = el.get("center")
    if center:
        return center.get("lat"), center.get("lon")
    return None, None


def to_restaurant(el: dict) -> Optional[dict]:
    tags = el.get("tags") or {}
    name = tags.get("name")
    if not name:
        return None

    cuisine = normalize_cuisine(tags.get("cuisine", ""))
    if not cuisine:
        return None

    lat, lon = element_center(el)
    city = guess_city(tags)
    country = guess_country(tags)

    if lat is None or lon is None or not city or not country:
        return None

    address = build_address(tags)
    if not address:
        return None

    return {
        "id": f"osm-{el.get('id')}",
        "name": name,
        "japanese_name": None,
        "cuisineType": cuisine,
        "priceRange": "¥¥",
        "country": country,
        "city": city,
        "latitude": lat,
        "longitude": lon,
        "address": address,
        "address_japanese": None,
        "phone": tags.get("phone"),
        "website": tags.get("website"),
        "google_maps_url": f"https://maps.google.com/?q={lat},{lon}",
        "rating": 4.0,
        "review_count": 0,
        "description": f"Authentic {cuisine} cuisine.",
        "description_japanese": None,
        "images": [],
        "cover_image": DEFAULT_COVER,
        "operating_hours": None,
        "features": [],
        "specialties": [],
        "menu_highlights": None,
        "price_range_details": None,
        "is_halal": False,
        "is_vegetarian": False,
        "has_vegan_options": False,
        "has_english_menu": True,
        "has_nepali_speaking_staff": cuisine in ["Nepali", "Himalayan", "Indo-Nepali"],
        "has_hindi_speaking_staff": cuisine in ["Indian", "North Indian", "South Indian", "Indo-Nepali"],
        "accepts_credit_card": True,
        "nearest_station": "",
        "walking_minutes": 0,
        "last_updated": dt.date.today().isoformat(),
    }


def build_dataset(elements: list[dict]) -> list[dict]:
    restaurants = []
    seen = set()
    for el in elements:
        r = to_restaurant(el)
        if not r:
            continue
        if r["id"] in seen:
            continue
        seen.add(r["id"])
        restaurants.append(r)
    return restaurants


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--country", action="append", default=[], help="Country name (e.g., Japan)")
    parser.add_argument("--bbox", action="append", default=[], help="minLat,minLon,maxLat,maxLon")
    parser.add_argument("--out", required=True, help="Output JSON path")
    args = parser.parse_args()

    query = overpass_query(args.country, args.bbox)
    data = fetch_overpass(query)
    restaurants = build_dataset(data.get("elements", []))

    payload = {
        "version": "2.0.0",
        "last_updated": dt.date.today().isoformat(),
        "total_count": len(restaurants),
        "restaurants": restaurants,
    }

    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    print(f"Wrote {len(restaurants)} restaurants to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
