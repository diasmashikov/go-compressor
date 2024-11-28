// test-100-users.js
import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  vus: 100,
  duration: "10s",
};

const img = open("./test-images/sample.png", "b");

export default function () {
  const url = `http://${__ENV.API_HOST}:8080/compress-image`;
  const formData = {
    image_files: http.file(img, "sample-under-test.png"),
    strategy: "bimg",
  };

  const response = http.post(url, formData);
  check(response, {
    "status is 200": (r) => r.status === 200,
    "response has content": (r) => r.body.length > 0,
  });
  sleep(1);
}
