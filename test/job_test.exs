defmodule JobTest do
  use ExUnit.Case

  import Mock

  test "creates a command from job payload" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQwMTIzVDE3NTc0NS0yODIzL1VudGl0bGVkLnBuZyJdLFsicCIsImNvbnZlcnQiLCItdGh1bWJuYWlsIDI3M3gyNzNeXiAtZ3Jhdml0eSBjZW50ZXIgLWNyb3AgMjczeDI3MyswKzAgK3JlcGFnZSAtZHJhdyAncG9seWdvbiAwLDAgMjczLDI3MyAyNzMsMCBmaWxsIG5vbmUgbWF0dGUgMTM1LDEzNSBmbG9vZGZpbGwnIiwicG5nIl1d"
    expected = %Steps{fetch: "#{System.get_env("HTTP_ENGINE_HOST")}/attachments/20140123T175745-2823/Untitled.png",
      convert: "#{Config.convert_command} - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' -strip png:-",
      format: "png"}
    assert(expected == Job.deserialize(payload))
  end

  test "supports a fetch only operation" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
    expected = %Steps{fetch: "#{System.get_env("HTTP_ENGINE_HOST")}/attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg",
                      convert: [],
                      file: nil,
                      format: "jpg"}
    assert(expected == Job.deserialize(payload))
  end

  test "supports local files" do
    payload = "W1siZmYiLCIvYXBwL2FwcC9hc3NldHMvaW1hZ2VzL2RlZmF1bHRfYXJ0aWNsZV9pbWFnZS5wbmciXSxbInAiLCJ0aHVtYiIsIjEwMHgxMDAjIl0sWyJlIiwianBnIl1d"
    expected = %Steps{file: "/app/app/assets/images/default_article_image.png", format: "jpg", convert: "#{Config.convert_command} - -resize 100x100^^ -gravity center -crop 100x100+0+0 +repage -strip jpg:-"}
    assert(expected == Job.deserialize(payload))
  end

  test "it creates the correct image" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQwMTIzVDE3NTc0NS0yODIzL1VudGl0bGVkLnBuZyJdLFsicCIsImNvbnZlcnQiLCItdGh1bWJuYWlsIDI3M3gyNzNeXiAtZ3Jhdml0eSBjZW50ZXIgLWNyb3AgMjczeDI3MyswKzAgK3JlcGFnZSAtZHJhdyAncG9seWdvbiAwLDAgMjczLDI3MyAyNzMsMCBmaWxsIG5vbmUgbWF0dGUgMTM1LDEzNSBmbG9vZGZpbGwnIiwicG5nIl1d"
    with_mock Engines.Http, [:passthrough], [fetch: fn(_url) -> {:ok, Fixtures.sample_image} end] do
      {"png", {:ok, data}} = Job.process(payload)
      assert data == Fixtures.sample_transformed_image
    end
  end
end
