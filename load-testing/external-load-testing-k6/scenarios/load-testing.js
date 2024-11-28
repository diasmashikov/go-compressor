import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 5,
  duration: "20s",
};

const img = open("/scripts/test-images/sample.png", "b");

export default function () {
  const url = `http://${__ENV.API_HOST}/compress-image`;
  const formData = {
    image_files: http.file(img, "sample-under-test.png"),
    strategy: "bimg",
  };

  const response = http.post(url, formData);
  check(response, {
    "status is 200": (r) => r.status === 200,
    "response has content": (r) => r.body.length > 0,
  });
}
