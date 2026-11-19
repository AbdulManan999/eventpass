import type { LatLngExpression } from 'leaflet'
import { useEffect } from 'react'
import { Circle, CircleMarker, MapContainer, TileLayer, Tooltip, useMap, useMapEvents } from 'react-leaflet'
import { useTheme } from '../theme/ThemeContext'

export interface MapPoint {
  id: string
  latitude: number
  longitude: number
  label: string
}

interface Props {
  latitude: number
  longitude: number
  radiusM: number
  /** Self check-in locations to plot inside the geofence. */
  points?: MapPoint[]
  /** When set, clicking the map moves the venue there. */
  onPick?: (latitude: number, longitude: number) => void
  className?: string
}

/** OpenStreetMap view of a venue and its geofence circle. */
export function VenueMap({ latitude, longitude, radiusM, points = [], onPick, className = 'h-72' }: Props) {
  const { chart } = useTheme()
  const center: LatLngExpression = [latitude, longitude]
  return (
    <MapContainer center={center} zoom={16} scrollWheelZoom={!!onPick} className={`z-0 w-full rounded-xl ${className}`}>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <Recenter latitude={latitude} longitude={longitude} radiusM={radiusM} />
      {onPick && <ClickToPick onPick={onPick} />}
      <Circle center={center} radius={radiusM} pathOptions={{ color: chart.venue, fillColor: chart.venueFill, fillOpacity: 0.12, weight: 2 }} />
      <CircleMarker center={center} radius={7} pathOptions={{ color: chart.markerRing, fillColor: chart.venue, fillOpacity: 1, weight: 3 }}>
        <Tooltip direction="top">Venue · geofence {radiusM} m</Tooltip>
      </CircleMarker>
      {points.map((p) => (
        <CircleMarker
          key={p.id}
          center={[p.latitude, p.longitude]}
          radius={5}
          pathOptions={{ color: chart.markerRing, fillColor: chart.methods.geofence, fillOpacity: 1, weight: 2 }}
        >
          <Tooltip>{p.label}</Tooltip>
        </CircleMarker>
      ))}
    </MapContainer>
  )
}

function Recenter({ latitude, longitude, radiusM }: { latitude: number; longitude: number; radiusM: number }) {
  const map = useMap()
  useEffect(() => {
    // Zoom so the whole geofence fits with some margin: one level out per doubling of the radius.
    const zoom = Math.max(13, Math.min(18, Math.round(16 - Math.log2(radiusM / 150))))
    map.setView([latitude, longitude], zoom, { animate: true })
  }, [map, latitude, longitude, radiusM])
  return null
}

function ClickToPick({ onPick }: { onPick: (latitude: number, longitude: number) => void }) {
  useMapEvents({
    click: (e) => onPick(Number(e.latlng.lat.toFixed(6)), Number(e.latlng.lng.toFixed(6))),
  })
  return null
}
