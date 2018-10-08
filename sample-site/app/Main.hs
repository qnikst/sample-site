import Prometheus
import Prometheus.Metric.GHC
import Sample.Server (run)

-- TODO: add configuration loading.

main :: IO ()
main = do
  _ <- register ghcMetrics
  run

